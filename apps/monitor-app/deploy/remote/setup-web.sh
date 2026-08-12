#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/target.conf"
ROOT="$(cd -- "$DIR/../.." && pwd)"
SSH=(-i "$DEPLOY_SSH_KEY" -o BatchMode=yes)
REMOTE="$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "Preparando .env remoto da Web."
python3 "$ROOT/deploy/core/env_tools.py" "$ROOT/apps/web/.env" "$TMP" \
  --set HOST=127.0.0.1 \
  --set PORT=4005 \
  --set PUBLIC_API_URL=/api
scp "${SSH[@]}" "$TMP" "$REMOTE:$DEPLOY_REMOTE_DIR/apps/web/.env" >/dev/null
echo ".env remoto da Web enviado."

ssh "${SSH[@]}" "$REMOTE" "bash -s" <<SH_REMOTE
set -Eeuo pipefail
cd '$DEPLOY_REMOTE_DIR/apps/web'
echo 'Parando serviço Web.'
sudo systemctl stop amazon-infra-monitor-web.service 2>/dev/null || true
rm -rf node_modules dist .astro
npm install
npm run build
cd '$DEPLOY_REMOTE_DIR/deploy/remote'
./start-web.sh
SH_REMOTE
