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
INFRA_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
API_PORT="$(sed -n 's/^APP_PORT=//p' "$INFRA_ROOT/.config/api/production/app.env")"
WEB_PORT="$(sed -n 's/^APP_PORT=//p' "$INFRA_ROOT/.config/web/production/app.env")"
curl -fsS --max-time 2 "http://127.0.0.1:${API_PORT}/api/health" >/dev/null
AUTH_STATUS="$(curl -sS --max-time 2 -o /dev/null -w '%{http_code}' "http://127.0.0.1:${API_PORT}/api/monitor")"
[[ "$AUTH_STATUS" == "401" ]] || { echo "Proteção SSO inválida: /api/monitor retornou HTTP $AUTH_STATUS sem sessão." >&2; exit 1; }
ROOT_STATUS="$(curl -sS --max-time 2 -o /dev/null -w '%{http_code}' "http://127.0.0.1:${WEB_PORT}/")"
ROOT_LOCATION="$(curl -sS --max-time 2 -D - -o /dev/null "http://127.0.0.1:${WEB_PORT}/" | tr -d '\r' | sed -n 's/^location: //Ip' | head -1)"
[[ "$ROOT_STATUS" == "302" ]] || { echo "Gate SSO inválido: / retornou HTTP $ROOT_STATUS sem sessão." >&2; exit 1; }
[[ "$ROOT_LOCATION" == "/api/api/auth/login" ]] || { echo "Gate SSO inválido: / redirecionou para '$ROOT_LOCATION'." >&2; exit 1; }
echo "Monitor App remoto validado: health público + raiz/API protegidas por SSO."
REMOTE
