#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"

BACKUP_DIR="$ROOT_DIR/backups/nginx-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Baixando backup do Nginx para: $BACKUP_DIR"
rsync -avz -e "ssh -i $SSH_KEY" "$REMOTE_USER@$REMOTE_HOST:/etc/nginx/" "$BACKUP_DIR/"
echo "OK: backup criado."
