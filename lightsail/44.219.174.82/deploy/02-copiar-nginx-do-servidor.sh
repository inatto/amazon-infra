#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./02-copiar-nginx-do-servidor.sh ../domains/orbital.anpprev.org.conf" >&2
  exit 1
}

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_USER:?Defina REMOTE_USER}"
: "${REMOTE_HOST:?Defina REMOTE_HOST}"
: "${SSH_KEY:?Defina SSH_KEY}"
[[ -f "$SSH_KEY" ]] || { echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2; exit 1; }
command -v rsync >/dev/null || { echo "ERRO: instale rsync no WSL." >&2; exit 1; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_NGINX_DIR="$SCRIPT_DIR/../server/etc/nginx"
mkdir -p "$LOCAL_NGINX_DIR"

rsync -avz \
  --delete \
  --no-owner \
  --no-group \
  -e "ssh -i $SSH_KEY -o BatchMode=yes -o ConnectTimeout=15" \
  --rsync-path="sudo rsync" \
  "$REMOTE_USER@$REMOTE_HOST:/etc/nginx/" \
  "$LOCAL_NGINX_DIR/"

echo "OK: /etc/nginx copiado para $LOCAL_NGINX_DIR"

