#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
WEB_DIR="$ROOT_DIR/apps/web"
APP_CONFIG="$WEB_DIR/config/local/app.env"
WEB_HOST="$(sed -n 's/^APP_HOST=//p' "$APP_CONFIG")"
WEB_PORT="$(sed -n 's/^APP_PORT=//p' "$APP_CONFIG")"
[[ "$WEB_HOST" == "127.0.0.1" ]] || { echo "APP_HOST inválido: $WEB_HOST" >&2; exit 1; }
[[ "$WEB_PORT" =~ ^[0-9]+$ ]] && ((WEB_PORT >= 1 && WEB_PORT <= 65535)) || { echo "APP_PORT inválido." >&2; exit 1; }
[[ -d "$WEB_DIR/node_modules" ]] || { echo "Web não preparada." >&2; exit 1; }

cd "$WEB_DIR"
echo "Iniciando Web local..."
setsid npm run dev &
PID=$!
cleanup() { trap - INT TERM EXIT; kill -TERM -- "-$PID" 2>/dev/null || true; wait "$PID" 2>/dev/null || true; }
trap cleanup INT TERM EXIT
for _ in {1..30}; do
  kill -0 "$PID" 2>/dev/null || { echo "Erro: Web local encerrou durante a inicialização." >&2; exit 1; }
  if curl -fsS --max-time 2 "http://127.0.0.1:${WEB_PORT}/" >/dev/null 2>&1; then
    echo "Web local iniciada."
    wait "$PID"
    exit $?
  fi
  sleep 1
done
echo "Erro: Web local não ficou pronta." >&2
exit 1
