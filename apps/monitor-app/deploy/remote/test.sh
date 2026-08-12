#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_FILE="${DEPLOY_TARGET_FILE:-$SCRIPT_DIR/target.conf}"
[[ -f "$TARGET_FILE" ]] || { echo "Destino não encontrado: $TARGET_FILE" >&2; exit 1; }
source "$TARGET_FILE"
SSH=(-i "$DEPLOY_SSH_KEY" -o BatchMode=yes)
ssh "${SSH[@]}" "$DEPLOY_REMOTE_HOST" 'bash -s' -- "$DEPLOY_REMOTE_ROOT" <<'REMOTE'
set -euo pipefail
ROOT_DIR="$1"
API_PORT="$(sed -n 's/^APP_PORT=//p' "$ROOT_DIR/apps/api/config/production/app.env")"
WEB_PORT="$(sed -n 's/^APP_PORT=//p' "$ROOT_DIR/apps/web/config/production/app.env")"
curl -fsS --max-time 2 "http://127.0.0.1:${API_PORT}/api/health" >/dev/null
curl -fsS --max-time 2 "http://127.0.0.1:${WEB_PORT}/" >/dev/null
echo "Monitor App remoto validado."
REMOTE
