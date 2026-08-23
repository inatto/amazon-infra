#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
API_DIR="$ROOT_DIR/apps/api"
APP_CONFIG="$INFRA_ROOT/.config/api/local/app.env"
[[ -f "$APP_CONFIG" ]] || { echo "Configuração da API não encontrada: $APP_CONFIG" >&2; exit 1; }
API_HOST="$(sed -n 's/^APP_HOST=//p' "$APP_CONFIG")"
API_PORT="$(sed -n 's/^APP_PORT=//p' "$APP_CONFIG")"
[[ "$API_HOST" == "127.0.0.1" ]] || { echo "APP_HOST inválido: $API_HOST" >&2; exit 1; }
[[ "$API_PORT" =~ ^[0-9]+$ ]] && ((API_PORT >= 1 && API_PORT <= 65535)) || { echo "APP_PORT inválido." >&2; exit 1; }

echo "Parando API local na porta $API_PORT..."
fuser -k "${API_PORT}/tcp" >/dev/null 2>&1 || true

echo "Preparando API..."
rm -rf "$API_DIR/.venv"
python3 -m venv "$API_DIR/.venv"
"$API_DIR/.venv/bin/pip" install -r "$API_DIR/requirements.txt"

echo "API preparada."
exec "$SCRIPT_DIR/start-api.sh"
