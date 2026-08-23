#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_FILE="${DEPLOY_TARGET_FILE:-$SCRIPT_DIR/target.conf}"
[[ -f "$TARGET_FILE" ]] || { echo "Destino não encontrado: $TARGET_FILE" >&2; exit 1; }
source "$TARGET_FILE"
SSH_KEY="${DEPLOY_SSH_KEY:?Defina DEPLOY_SSH_KEY em $TARGET_FILE}"
REMOTE_HOST="${DEPLOY_REMOTE_HOST:?Defina DEPLOY_REMOTE_HOST em $TARGET_FILE}"
REMOTE_ROOT="${DEPLOY_REMOTE_ROOT:?Defina DEPLOY_REMOTE_ROOT em $TARGET_FILE}"
SSH=(-i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=15 -o ServerAliveInterval=30 -o ServerAliveCountMax=120)

echo "Parando e preparando API remota..."
ssh "${SSH[@]}" "$REMOTE_HOST" 'bash -s' -- "$REMOTE_ROOT" <<'REMOTE'
set -euo pipefail
ROOT_DIR="$1"
INFRA_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
API_DIR="$ROOT_DIR/apps/api"
APP_CONFIG="$INFRA_ROOT/.config/api/production/app.env"
[[ -f "$APP_CONFIG" ]] || { echo "Configuração da API não encontrada: $APP_CONFIG" >&2; exit 1; }
API_HOST="$(sed -n 's/^APP_HOST=//p' "$APP_CONFIG")"
API_PORT="$(sed -n 's/^APP_PORT=//p' "$APP_CONFIG")"
API_SERVICE="$(sed -n 's/^API_SYSTEMD_SERVICE=//p' "$APP_CONFIG")"
[[ "$API_HOST" == "127.0.0.1" ]] || { echo "APP_HOST inválido: $API_HOST" >&2; exit 1; }
[[ "$API_PORT" =~ ^[0-9]+$ ]] && ((API_PORT >= 1 && API_PORT <= 65535)) || { echo "APP_PORT inválido." >&2; exit 1; }
[[ "$API_SERVICE" =~ ^[A-Za-z0-9_.@:-]+\.service$ ]] || { echo "API_SYSTEMD_SERVICE inválido." >&2; exit 1; }

sudo systemctl stop "$API_SERVICE" 2>/dev/null || true
sudo fuser -k "${API_PORT}/tcp" >/dev/null 2>&1 || true

EXTERNAL="$INFRA_ROOT/.config/api/production/services.env.external"
LEGACY_EXTERNAL="$API_DIR/config/production/services.env.external"
LEGACY="$API_DIR/.env"
mkdir -p "$(dirname "$EXTERNAL")"
if [[ ! -f "$EXTERNAL" && -f "$LEGACY" ]]; then
    token="$(sed -n 's/^INFRA_ADMIN_TOKEN=//p' "$LEGACY" | head -1)"
    if [[ -n "$token" ]]; then
        printf 'INFRA_ADMIN_TOKEN=%s\n' "$token" > "$EXTERNAL"
        chmod 0600 "$EXTERNAL"
        echo "INFRA_ADMIN_TOKEN legado preservado em services.env.external."
    fi
fi
rm -f "$LEGACY"
if [[ ! -f "$EXTERNAL" ]]; then
    touch "$EXTERNAL"
fi
if ! grep -Eq '^SSO_SESSION_SECRET=.+$' "$EXTERNAL" 2>/dev/null; then
    session_secret="$(python3 -c 'import secrets; print(secrets.token_urlsafe(48))')"
    printf 'SSO_SESSION_SECRET=%s\n' "$session_secret" >> "$EXTERNAL"
    echo "SSO_SESSION_SECRET gerado e preservado em services.env.external."
fi
chmod 0600 "$EXTERNAL"
if ! grep -Eq '^INFRA_ADMIN_TOKEN=.+$' "$EXTERNAL" 2>/dev/null \
   && ! grep -Eq '^INFRA_ADMIN_TOKEN=.+$' "$LEGACY_EXTERNAL" 2>/dev/null; then
    echo "Aviso: INFRA_ADMIN_TOKEN não configurado; administração web ficará somente leitura." >&2
fi

cd "$API_DIR"
rm -rf .venv
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
"$ROOT_DIR/deploy/remote/systemd/install.sh" "$ROOT_DIR" "$API_SERVICE"
REMOTE

echo "API remota preparada."
exec "$SCRIPT_DIR/start-api.sh"
