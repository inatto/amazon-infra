#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./02-configurar-nginx.sh ../domains/<dominio>.conf" >&2
  exit 1
}

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_USER:?Defina REMOTE_USER}"
: "${REMOTE_HOST:?Defina REMOTE_HOST}"
: "${SSH_KEY:?Defina SSH_KEY}"
: "${SITE_NAME:?Defina SITE_NAME}"
: "${APP_NAME:?Defina APP_NAME}"
: "${WEB_UPSTREAM_HOST:?Defina WEB_UPSTREAM_HOST}"
: "${WEB_UPSTREAM_PORT:?Defina WEB_UPSTREAM_PORT}"
declare -p DOMAINS >/dev/null 2>&1 && (( ${#DOMAINS[@]} > 0 )) || {
  echo "ERRO: defina DOMAINS no arquivo do domínio." >&2
  exit 1
}
[[ -f "$SSH_KEY" ]] || { echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2; exit 1; }

for command_name in ssh scp; do
  command -v "$command_name" >/dev/null || {
    echo "ERRO: $command_name não encontrado." >&2
    exit 1
  }
done

REMOTE_AVAILABLE="/etc/nginx/sites-available"
REMOTE_ENABLED="/etc/nginx/sites-enabled"
DOMAIN_LIST="${DOMAINS[*]}"
PRIMARY_DOMAIN="${DOMAINS[0]}"
GENERATED_FILE="$(mktemp)"
REMOTE_TMP="/tmp/$SITE_NAME.nginx.$$"
RESTORE_TMP="/tmp/$SITE_NAME.restore.$$"
CHANGED=false
HAD_PREVIOUS=false

SSH_OPTIONS=(-i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=15)
remote() { ssh "${SSH_OPTIONS[@]}" "$REMOTE_USER@$REMOTE_HOST" "$@"; }

cleanup() {
  rm -f "$GENERATED_FILE"
  remote "rm -f '$REMOTE_TMP' '$RESTORE_TMP'" >/dev/null 2>&1 || true
}

rollback() {
  local status=$?
  trap - ERR

  if [[ "$CHANGED" == true ]]; then
    echo "Falha. Restaurando a configuração anterior de $SITE_NAME..." >&2
    if [[ "$HAD_PREVIOUS" == true ]]; then
      remote "sudo install -m 0644 '$RESTORE_TMP' '$REMOTE_AVAILABLE/$SITE_NAME'; sudo ln -sfn '$REMOTE_AVAILABLE/$SITE_NAME' '$REMOTE_ENABLED/$SITE_NAME'; sudo nginx -t; sudo systemctl reload nginx"
    else
      remote "sudo rm -f '$REMOTE_AVAILABLE/$SITE_NAME' '$REMOTE_ENABLED/$SITE_NAME'; sudo nginx -t; sudo systemctl reload nginx"
    fi
  fi

  cleanup
  exit "$status"
}
trap rollback ERR
trap cleanup EXIT

remote "sudo nginx -t && systemctl is-active --quiet nginx"

if remote "sudo test -f '$REMOTE_AVAILABLE/$SITE_NAME'"; then
  remote "sudo cp -a '$REMOTE_AVAILABLE/$SITE_NAME' '$RESTORE_TMP'; sudo chown '$REMOTE_USER:$REMOTE_USER' '$RESTORE_TMP'"
  HAD_PREVIOUS=true
fi

SSL_ENABLED=false
if remote "sudo test -s '/etc/letsencrypt/live/$PRIMARY_DOMAIN/fullchain.pem' && sudo test -s '/etc/letsencrypt/live/$PRIMARY_DOMAIN/privkey.pem'"; then
  SSL_ENABLED=true
fi

if [[ "$SSL_ENABLED" == true ]]; then
  cat > "$GENERATED_FILE" <<NGINX
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN_LIST;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $DOMAIN_LIST;

    ssl_certificate /etc/letsencrypt/live/$PRIMARY_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$PRIMARY_DOMAIN/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    add_header X-Site-App "$APP_NAME" always;
    client_max_body_size ${CLIENT_MAX_BODY_SIZE:-20m};
NGINX
else
  cat > "$GENERATED_FILE" <<NGINX
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN_LIST;

    add_header X-Site-App "$APP_NAME" always;
    client_max_body_size ${CLIENT_MAX_BODY_SIZE:-20m};
NGINX
fi

if [[ -n "${API_UPSTREAM_PORT:-}" ]]; then
  cat >> "$GENERATED_FILE" <<NGINX

    location = /api {
        return 308 /api/;
    }

    location /api/ {
        proxy_pass http://${API_UPSTREAM_HOST:-$WEB_UPSTREAM_HOST}:$API_UPSTREAM_PORT/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout ${API_PROXY_CONNECT_TIMEOUT:-30s};
        proxy_send_timeout ${API_PROXY_SEND_TIMEOUT:-120s};
        proxy_read_timeout ${API_PROXY_READ_TIMEOUT:-120s};
    }
NGINX
fi

cat >> "$GENERATED_FILE" <<NGINX

    location / {
        proxy_pass http://$WEB_UPSTREAM_HOST:$WEB_UPSTREAM_PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout ${WEB_PROXY_READ_TIMEOUT:-60s};
    }
}
NGINX

printf 'Configuração que será publicada em %s/%s:\n' "$REMOTE_AVAILABLE" "$SITE_NAME"
sed -n '1,240p' "$GENERATED_FILE"
printf '\n'
read -r -p "Digite PUBLICAR para continuar: " CONFIRMATION
[[ "$CONFIRMATION" == "PUBLICAR" ]] || { echo "Cancelado."; exit 1; }

scp "${SSH_OPTIONS[@]}" "$GENERATED_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_TMP" >/dev/null
CHANGED=true
remote "sudo install -m 0644 '$REMOTE_TMP' '$REMOTE_AVAILABLE/$SITE_NAME'; sudo ln -sfn '$REMOTE_AVAILABLE/$SITE_NAME' '$REMOTE_ENABLED/$SITE_NAME'; sudo nginx -t; sudo systemctl reload nginx"
CHANGED=false

echo "OK: Nginx configurado para $DOMAIN_LIST"
