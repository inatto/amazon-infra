#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./03-instalar-ssl.sh ../domains/<dominio>.conf" >&2
  exit 1
}

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_USER:?Defina REMOTE_USER}"
: "${REMOTE_HOST:?Defina REMOTE_HOST}"
: "${SSH_KEY:?Defina SSH_KEY}"
: "${SSL_EMAIL:?Defina SSL_EMAIL}"
declare -p DOMAINS >/dev/null 2>&1 && (( ${#DOMAINS[@]} > 0 )) || {
  echo "ERRO: defina DOMAINS no arquivo do domínio." >&2
  exit 1
}
[[ -f "$SSH_KEY" ]] || { echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2; exit 1; }
command -v ssh >/dev/null || { echo "ERRO: ssh não encontrado." >&2; exit 1; }

SSH_OPTIONS=(-i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=15)
remote() { ssh "${SSH_OPTIONS[@]}" "$REMOTE_USER@$REMOTE_HOST" "$@"; }

if ! remote "command -v certbot >/dev/null && sudo certbot plugins 2>/dev/null | grep -q 'nginx'"; then
  echo "ERRO: Certbot com plugin Nginx não está instalado no servidor." >&2
  echo "Execute no servidor: sudo apt update && sudo apt install -y certbot python3-certbot-nginx" >&2
  exit 1
fi

CERTBOT_DOMAINS=""
for domain in "${DOMAINS[@]}"; do
  printf -v CERTBOT_DOMAINS '%s -d %q' "$CERTBOT_DOMAINS" "$domain"
done

remote "sudo certbot --nginx --non-interactive --agree-tos --no-eff-email --redirect --keep-until-expiring --cert-name '${DOMAINS[0]}' -m '$SSL_EMAIL' $CERTBOT_DOMAINS"

echo "OK: SSL instalado para ${DOMAINS[*]}"
