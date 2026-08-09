#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/target.conf"
ROOT="$(cd -- "$DIR/../.." && pwd)"
SSH=(-i "$DEPLOY_SSH_KEY" -o BatchMode=yes)

echo "Sincronizando código com $DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST:$DEPLOY_REMOTE_DIR."
ssh "${SSH[@]}" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST" "mkdir -p '$DEPLOY_REMOTE_DIR'"
rsync -az --delete \
  --exclude '.env' \
  --exclude '.venv' \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --exclude '.astro' \
  --exclude '__pycache__' \
  -e "ssh -i $DEPLOY_SSH_KEY -o BatchMode=yes" \
  "$ROOT/" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST:$DEPLOY_REMOTE_DIR/"
echo "Código remoto sincronizado."

ssh "${SSH[@]}" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST" \
  "cd '$DEPLOY_REMOTE_DIR/deploy/remote' && ./setup-services.sh"
echo "Serviços systemd do monitor garantidos."

"$DIR/setup-api.sh"
"$DIR/setup-web.sh"
