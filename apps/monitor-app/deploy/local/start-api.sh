#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
API_DIR="$ROOT_DIR/apps/api"
APP_CONFIG="$INFRA_ROOT/.config/api/local/app.env"
PYTHON="$API_DIR/.venv/bin/python"
UVICORN="$API_DIR/.venv/bin/uvicorn"
[[ -x "$PYTHON" && -x "$UVICORN" ]] || { echo "API não preparada." >&2; exit 1; }
API_PORT="$(sed -n 's/^APP_PORT=//p' "$APP_CONFIG")"
API_HOST="$(sed -n 's/^APP_HOST=//p' "$APP_CONFIG")"
[[ "$API_HOST" == "127.0.0.1" ]] || { echo "APP_HOST inválido: $API_HOST" >&2; exit 1; }
[[ "$API_PORT" =~ ^[0-9]+$ ]] && ((API_PORT >= 1 && API_PORT <= 65535)) || { echo "APP_PORT inválido." >&2; exit 1; }

cd "$API_DIR"
echo "Iniciando API local..."
setsid "$UVICORN" main:app --host "$API_HOST" --port "$API_PORT" &
PID=$!
cleanup() { trap - INT TERM EXIT; kill -TERM -- "-$PID" 2>/dev/null || true; wait "$PID" 2>/dev/null || true; }
trap cleanup INT TERM EXIT
for _ in {1..30}; do
  kill -0 "$PID" 2>/dev/null || { echo "Erro: API local encerrou durante a inicialização." >&2; exit 1; }
  if curl -fsS --max-time 2 "http://127.0.0.1:${API_PORT}/api/health" >/dev/null 2>&1; then
    echo "API local iniciada."
    wait "$PID"
    exit $?
  fi
  sleep 1
done
echo "Erro: API local não ficou pronta." >&2
exit 1
