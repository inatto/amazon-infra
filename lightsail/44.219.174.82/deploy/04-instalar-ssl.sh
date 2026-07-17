#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./04-instalar-ssl.sh ../domains/orbital.anpprev.org.conf" >&2
  exit 1
}

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_USER:?Defina REMOTE_USER}"
: "${REMOTE_HOST:?Defina REMOTE_HOST}"
: "${SSH_KEY:?Defina SSH_KEY}"
: "${SSL_EMAIL:?Defina SSL_EMAIL}"
[[ ${#DOMAINS[@]} -gt 0 ]] || { echo "ERRO: informe DOMAINS." >&2; exit 1; }

SSH_OPTIONS=(-i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=15)
remote() { ssh "${SSH_OPTIONS[@]}" "$REMOTE_USER@$REMOTE_HOST" "$@"; }

if ! remote "command -v certbot >/dev/null && sudo certbot plugins 2>/dev/null | grep -q 'nginx'"; then
  echo "Certbot para Nginx não está instalado. Execute:" >&2
  echo "ssh -i $SSH_KEY $REMOTE_USER@$REMOTE_HOST 'sudo apt update && sudo apt install -y certbot python3-certbot-nginx'" >&2
  echo "Depois execute novamente este passo 04." >&2
  exit 1
fi

CERTBOT_DOMAINS=""
for domain in "${DOMAINS[@]}"; do
  printf -v CERTBOT_DOMAINS '%s -d %q' "$CERTBOT_DOMAINS" "$domain"
done

remote "sudo certbot --nginx --non-interactive --agree-tos --no-eff-email --redirect --keep-until-expiring --cert-name '${DOMAINS[0]}' -m '$SSL_EMAIL' $CERTBOT_DOMAINS"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/02-copiar-nginx-do-servidor.sh" "$CONFIG_FILE"
echo "OK: SSL instalado para ${DOMAINS[*]}"

