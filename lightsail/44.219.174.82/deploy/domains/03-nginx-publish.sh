#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
set -Eeuo pipefail

DOMAIN_CONFIG="${1:-}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_load-config.sh"
source "$SCRIPT_DIR/_render-nginx.sh"

require_command scp
require_command ssh

echo "Verificando o Nginx atual..."
remote "sudo nginx -t && systemctl is-active --quiet nginx"

echo "Verificando conflito de server_name..."
for domain in "${DOMAINS[@]}"; do
  conflicts="$(remote "sudo grep -RIl -E 'server_name[[:space:]][^;]*([^A-Za-z0-9.-]|^)$domain([^A-Za-z0-9.-]|$)' '$REMOTE_ENABLED' 2>/dev/null || true")"
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    [[ "$file" == "$REMOTE_ENABLED/$SITE_NAME" ]] && continue
    echo "ERRO: $domain já está habilitado em $file" >&2
    exit 1
  done <<< "$conflicts"
done

[[ -f "$LOCAL_NGINX_PATH/nginx.conf" ]] || {
  echo "ERRO: espelho local do Nginx não encontrado." >&2
  echo "Execute primeiro: ./02-nginx-backup.sh" >&2
  exit 1
}

generated_file="$(mktemp)"
remote_tmp="/tmp/${SITE_NAME}.nginx.$$"
restore_tmp="/tmp/${SITE_NAME}.restore.$$"
changed_remote="false"
old_available="false"
old_enabled="false"

[[ -f "$LOCAL_SITE_FILE" ]] && old_available="true"
[[ -e "$LOCAL_NGINX_PATH/sites-enabled/$SITE_NAME" || -L "$LOCAL_NGINX_PATH/sites-enabled/$SITE_NAME" ]] && old_enabled="true"

cleanup() {
  rm -f "$generated_file"
  remote "rm -f '$remote_tmp' '$restore_tmp'" >/dev/null 2>&1 || true
}

rollback_on_error() {
  local status=$?
  trap - ERR
  if [[ "$changed_remote" == "true" ]]; then
    echo "Falha detectada. Restaurando automaticamente $SITE_NAME..." >&2
    if [[ "$old_available" == "true" ]]; then
      scp "${SSH_OPTIONS[@]}" "$LOCAL_SITE_FILE" "$REMOTE_USER@$REMOTE_HOST:$restore_tmp" >/dev/null
      remote "sudo install -m 0644 '$restore_tmp' '$REMOTE_AVAILABLE/$SITE_NAME'"
    else
      remote "sudo rm -f '$REMOTE_AVAILABLE/$SITE_NAME'"
    fi

    if [[ "$old_enabled" == "true" ]]; then
      remote "sudo ln -sfn '$REMOTE_AVAILABLE/$SITE_NAME' '$REMOTE_ENABLED/$SITE_NAME'"
    else
      remote "sudo rm -f '$REMOTE_ENABLED/$SITE_NAME'"
    fi

    remote "sudo nginx -t && sudo systemctl reload nginx" || {
      echo "ERRO: o restore automático falhou. O espelho anterior continua em $LOCAL_NGINX_PATH" >&2
    }
  fi
  exit "$status"
}

trap rollback_on_error ERR
trap cleanup EXIT

render_nginx "$generated_file"

echo
echo "Configuração que será publicada:"
echo "$REMOTE_AVAILABLE/$SITE_NAME"
echo
sed -n '1,240p' "$generated_file"
echo
read -r -p "Digite PUBLICAR para alterar somente $SITE_NAME: " confirmation
[[ "$confirmation" == "PUBLICAR" ]] || {
  echo "Publicação cancelada."
  exit 1
}

scp "${SSH_OPTIONS[@]}" "$generated_file" "$REMOTE_USER@$REMOTE_HOST:$remote_tmp" >/dev/null
changed_remote="true"
remote "
  set -e
  sudo install -m 0644 '$remote_tmp' '$REMOTE_AVAILABLE/$SITE_NAME'
  sudo ln -sfn '$REMOTE_AVAILABLE/$SITE_NAME' '$REMOTE_ENABLED/$SITE_NAME'
  sudo nginx -t
  sudo systemctl reload nginx
"

changed_remote="false"
"$SCRIPT_DIR/02-nginx-backup.sh" "$DOMAIN_CONFIG"
echo "OK: configuração publicada e Nginx recarregado."
