#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
set -Eeuo pipefail

DOMAIN_CONFIG="${1:-}"
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/_load-config.sh"

require_command rsync
require_command ssh

mkdir -p "$LOCAL_NGINX_PATH"

echo "Copiando o Nginx do servidor para o espelho local..."
echo "Origem : $REMOTE_USER@$REMOTE_HOST:/etc/nginx/"
echo "Destino: $LOCAL_NGINX_PATH/"
echo

rsync -avz \
  --delete \
  --no-owner \
  --no-group \
  -e "ssh -i $SSH_KEY -o BatchMode=yes -o ConnectTimeout=15" \
  --rsync-path="sudo rsync" \
  "$REMOTE_USER@$REMOTE_HOST:/etc/nginx/" \
  "$LOCAL_NGINX_PATH/"

echo
echo "OK: /etc/nginx sincronizado em:"
echo "$LOCAL_NGINX_PATH"
