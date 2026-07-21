#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./04-instalar-servicos.sh ../domains/<dominio>.conf" >&2
  exit 1
}
CONFIG_FILE="$(cd -- "$(dirname -- "$CONFIG_FILE")" && pwd)/$(basename -- "$CONFIG_FILE")"

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_USER:?Defina REMOTE_USER}"
: "${REMOTE_HOST:?Defina REMOTE_HOST}"
: "${SSH_KEY:?Defina SSH_KEY}"
[[ -f "$SSH_KEY" ]] || { echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2; exit 1; }

if ! declare -p SYSTEMD_SERVICES >/dev/null 2>&1 || (( ${#SYSTEMD_SERVICES[@]} == 0 )); then
  echo "Nenhum serviço systemd configurado para este domínio."
  exit 0
fi

for command_name in ssh scp; do
  command -v "$command_name" >/dev/null || {
    echo "ERRO: $command_name não encontrado." >&2
    exit 1
  }
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SYSTEMD_DIR="$SCRIPT_DIR/../server/etc/systemd/system"
SSH_OPTIONS=(-i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=15)
remote() { ssh "${SSH_OPTIONS[@]}" "$REMOTE_USER@$REMOTE_HOST" "$@"; }
mkdir -p "$LOCAL_SYSTEMD_DIR"

service_prefix() {
  printf '%s\n' "${1%.service}" | sed -E 's/-(api|web)$//'
}

app_directory() {
  local user="${SYSTEMD_USER:-$REMOTE_USER}"
  printf '%s\n' "${REMOTE_APP_DIR:-/home/$user/apps/$APP_NAME}"
}

generate_api_service() {
  local service="$1" app_dir working_dir
  : "${APP_NAME:?Defina APP_NAME para gerar automaticamente $service}"
  : "${API_UPSTREAM_PORT:?Defina API_UPSTREAM_PORT para gerar automaticamente $service}"

  app_dir="$(app_directory)"
  working_dir="${API_WORKING_DIRECTORY:-$app_dir/apps/api}"

  cat > "$LOCAL_SYSTEMD_DIR/$service" <<EOF_API
[Unit]
Description=${API_SERVICE_DESCRIPTION:-${APP_NAME} API FastAPI}
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${SYSTEMD_USER:-$REMOTE_USER}
Group=${SYSTEMD_GROUP:-${SYSTEMD_USER:-$REMOTE_USER}}
WorkingDirectory=$working_dir
EnvironmentFile=${API_ENVIRONMENT_FILE:-$working_dir/.env}
ExecStart=$working_dir/.venv/bin/uvicorn ${API_UVICORN_MODULE:-main:app} --host ${API_UPSTREAM_HOST:-127.0.0.1} --port $API_UPSTREAM_PORT --workers ${API_WORKERS:-2}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF_API

  echo "GERADO: server/etc/systemd/system/$service"
}

generate_web_service() {
  local service="$1" prefix app_dir working_dir
  : "${APP_NAME:?Defina APP_NAME para gerar automaticamente $service}"
  : "${WEB_UPSTREAM_PORT:?Defina WEB_UPSTREAM_PORT para gerar automaticamente $service}"

  prefix="$(service_prefix "$service")"
  app_dir="$(app_directory)"
  working_dir="${WEB_WORKING_DIRECTORY:-$app_dir/apps/web}"

  cat > "$LOCAL_SYSTEMD_DIR/$service" <<EOF_WEB
[Unit]
Description=${WEB_SERVICE_DESCRIPTION:-${APP_NAME} Astro Web}
After=network-online.target ${WEB_AFTER_SERVICE:-$prefix-api.service}
Wants=network-online.target

[Service]
Type=simple
User=${SYSTEMD_USER:-$REMOTE_USER}
Group=${SYSTEMD_GROUP:-${SYSTEMD_USER:-$REMOTE_USER}}
WorkingDirectory=$working_dir
EnvironmentFile=${WEB_ENVIRONMENT_FILE:-$working_dir/.env}
Environment=NODE_ENV=production
Environment=HOST=${WEB_UPSTREAM_HOST:-127.0.0.1}
Environment=PORT=$WEB_UPSTREAM_PORT
ExecStart=/usr/bin/node $working_dir/dist/server/entry.mjs
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF_WEB

  echo "GERADO: server/etc/systemd/system/$service"
}

generate_service_if_missing() {
  local service="$1"
  [[ -f "$LOCAL_SYSTEMD_DIR/$service" ]] && return

  case "$service" in
    *-api.service) generate_api_service "$service" ;;
    *-web.service) generate_web_service "$service" ;;
    *)
      echo "ERRO: não existe modelo automático para $service." >&2
      echo "Crie manualmente: $LOCAL_SYSTEMD_DIR/$service" >&2
      exit 1
      ;;
  esac
}

for service in "${SYSTEMD_SERVICES[@]}"; do
  [[ "$service" =~ ^[A-Za-z0-9_.@-]+\.service$ ]] || {
    echo "ERRO: serviço inválido: $service" >&2
    exit 1
  }
  generate_service_if_missing "$service"
  [[ -s "$LOCAL_SYSTEMD_DIR/$service" ]] || {
    echo "ERRO: arquivo vazio: $LOCAL_SYSTEMD_DIR/$service" >&2
    exit 1
  }
done

printf 'Serviços que serão instalados e habilitados: %s\n' "${SYSTEMD_SERVICES[*]}"
echo "Eles não serão iniciados; isso fica a cargo do deploy da aplicação."
read -r -p "Digite INSTALAR para continuar: " CONFIRMATION
[[ "$CONFIRMATION" == "INSTALAR" ]] || { echo "Cancelado."; exit 1; }

for service in "${SYSTEMD_SERVICES[@]}"; do
  remote_tmp="/tmp/$service.$$"
  scp "${SSH_OPTIONS[@]}" "$LOCAL_SYSTEMD_DIR/$service" "$REMOTE_USER@$REMOTE_HOST:$remote_tmp" >/dev/null
  remote "sudo install -m 0644 '$remote_tmp' '/etc/systemd/system/$service'; rm -f '$remote_tmp'"
done

remote "sudo systemctl daemon-reload"
for service in "${SYSTEMD_SERVICES[@]}"; do
  remote "sudo systemctl enable '$service'"
done

echo "OK: serviços instalados e habilitados, sem iniciar a aplicação."
