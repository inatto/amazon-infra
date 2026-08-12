#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_FILE="${DEPLOY_TARGET_FILE:-$SCRIPT_DIR/target.conf}"

[[ -f "$TARGET_FILE" ]] || {
    echo "Destino não encontrado: $TARGET_FILE" >&2
    exit 1
}

# shellcheck source=/dev/null
source "$TARGET_FILE"

SSH_KEY="${DEPLOY_SSH_KEY:?Defina DEPLOY_SSH_KEY em $TARGET_FILE}"
REMOTE_HOST="${DEPLOY_REMOTE_HOST:?Defina DEPLOY_REMOTE_HOST em $TARGET_FILE}"
REMOTE_ROOT="${DEPLOY_REMOTE_ROOT:?Defina DEPLOY_REMOTE_ROOT em $TARGET_FILE}"
SSH=(-i "$SSH_KEY" -o BatchMode=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=120)

echo "Iniciando Web remota..."
ssh "${SSH[@]}" "$REMOTE_HOST" 'bash -s' -- "$REMOTE_ROOT" <<'REMOTE'
set -euo pipefail

ROOT_DIR="$1"
APP_CONFIG="$ROOT_DIR/apps/web/config/production/app.env"
[[ -f "$APP_CONFIG" ]] || { echo "Configuração da Web não encontrada: $APP_CONFIG" >&2; exit 1; }
WEB_HOST="$(sed -n 's/^APP_HOST=//p' "$APP_CONFIG")"
WEB_PORT="$(sed -n 's/^APP_PORT=//p' "$APP_CONFIG")"
WEB_SERVICE="$(sed -n 's/^WEB_SYSTEMD_SERVICE=//p' "$APP_CONFIG")"

[[ "$WEB_HOST" == "127.0.0.1" ]] || { echo "APP_HOST inválido: $WEB_HOST" >&2; exit 1; }
[[ "$WEB_PORT" =~ ^[0-9]+$ ]] && ((WEB_PORT >= 1 && WEB_PORT <= 65535)) || { echo "APP_PORT inválido." >&2; exit 1; }
[[ "$WEB_SERVICE" =~ ^[A-Za-z0-9_.@:-]+\.service$ ]] || { echo "WEB_SYSTEMD_SERVICE inválido." >&2; exit 1; }

sudo systemctl restart "$WEB_SERVICE"
for _ in {1..30}; do
    systemctl is-active --quiet "$WEB_SERVICE" || {
        echo "Erro: $WEB_SERVICE não está ativo." >&2
        sudo systemctl status "$WEB_SERVICE" --no-pager -l >&2 || true
        sudo journalctl -u "$WEB_SERVICE" -n 40 --no-pager >&2 || true
        exit 1
    }
    if curl -fsS --max-time 2 "http://127.0.0.1:${WEB_PORT}/" >/dev/null 2>&1; then
        exit 0
    fi
    sleep 1
done

echo "Erro: Web não respondeu em http://127.0.0.1:${WEB_PORT}/." >&2
exit 1
REMOTE

echo "Web remota iniciada."
