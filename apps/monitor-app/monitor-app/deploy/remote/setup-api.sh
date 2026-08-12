#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/target.conf"
ROOT="$(cd -- "$DIR/../.." && pwd)"
SSH=(-i "$DEPLOY_SSH_KEY" -o BatchMode=yes)
REMOTE="$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "Preparando .env remoto da API."
python3 "$ROOT/deploy/core/env_tools.py" "$ROOT/apps/api/.env" "$TMP" \
  --set APP_HOST=127.0.0.1 \
  --set APP_PORT=8005 \
  --set CORS_ORIGINS=https://monitor.inatto.com

ADMIN_TOKEN="$(awk -F= '$1=="INFRA_ADMIN_TOKEN"{sub(/^[^=]*=/,""); print; exit}' "$TMP")"
if [[ -z "$ADMIN_TOKEN" ]]; then
  ADMIN_TOKEN="$(ssh "${SSH[@]}" "$REMOTE" "awk -F= '\$1==\"INFRA_ADMIN_TOKEN\"{sub(/^[^=]*=/,\"\"); print; exit}' '$DEPLOY_REMOTE_DIR/apps/api/.env' 2>/dev/null || true")"
fi
if [[ -z "$ADMIN_TOKEN" ]]; then
  ADMIN_TOKEN="$(openssl rand -hex 24)"
  echo "Novo INFRA_ADMIN_TOKEN gerado para o painel."
fi
python3 "$ROOT/deploy/core/env_tools.py" "$TMP" "$TMP.next" --set "INFRA_ADMIN_TOKEN=$ADMIN_TOKEN"
mv "$TMP.next" "$TMP"

scp "${SSH[@]}" "$TMP" "$REMOTE:$DEPLOY_REMOTE_DIR/apps/api/.env" >/dev/null
echo ".env remoto da API enviado."

ssh "${SSH[@]}" "$REMOTE" "bash -s" <<SH_REMOTE
set -Eeuo pipefail
cd '$DEPLOY_REMOTE_DIR/apps/api'
echo 'Parando serviço da API.'
sudo systemctl stop amazon-infra-monitor-api.service 2>/dev/null || true
rm -rf .venv __pycache__
python3 -m venv .venv
.venv/bin/pip install -q -r requirements.txt
cd '$DEPLOY_REMOTE_DIR/deploy/remote'
./start-api.sh
SH_REMOTE

echo
echo "INFRA_ADMIN_TOKEN=$ADMIN_TOKEN"
echo "Use este token no campo administrativo de https://monitor.inatto.com"
