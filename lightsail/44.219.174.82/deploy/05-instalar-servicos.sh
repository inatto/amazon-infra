#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/lightsail/44.219.174.82/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./05-instalar-servicos.sh ../domains/orbital.anpprev.org.conf" >&2
  exit 1
}

CONFIG_FILE="$(cd -- "$(dirname -- "$CONFIG_FILE")" && pwd)/$(basename -- "$CONFIG_FILE")"

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_USER:?Defina REMOTE_USER}"
: "${REMOTE_HOST:?Defina REMOTE_HOST}"
: "${SSH_KEY:?Defina SSH_KEY}"

if ! declare -p SYSTEMD_SERVICES >/dev/null 2>&1 || [[ ${#SYSTEMD_SERVICES[@]} -eq 0 ]]; then
  echo "Nenhum serviço systemd configurado para este domínio."
  exit 0
fi

: "${APP_NAME:?Defina APP_NAME em $CONFIG_FILE}"
: "${REMOTE_APP_DIR:?Defina REMOTE_APP_DIR em $CONFIG_FILE}"
[[ "$REMOTE_APP_DIR" == /* && "$REMOTE_APP_DIR" != *'..'* ]] || {
  echo "ERRO: REMOTE_APP_DIR deve ser um caminho absoluto sem '..': $REMOTE_APP_DIR" >&2
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SYSTEMD_DIR="$SCRIPT_DIR/../server/etc/systemd/system"
SSH_OPTIONS=(-i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=15)
remote() { ssh "${SSH_OPTIONS[@]}" "$REMOTE_USER@$REMOTE_HOST" "$@"; }

mkdir -p "$LOCAL_SYSTEMD_DIR"

service_prefix() {
  local service="$1"
  printf '%s\n' "${service%.service}" | sed -E 's/-(api|web)$//'
}

generate_api_service() {
  local service="$1"
  local prefix app_dir working_dir env_file module host port description

  : "${API_UPSTREAM_PORT:?Defina API_UPSTREAM_PORT para gerar automaticamente $service}"

  prefix="$(service_prefix "$service")"
  app_dir="$REMOTE_APP_DIR"
  working_dir="${API_WORKING_DIRECTORY:-$app_dir/apps/api}"
  env_file="${API_ENVIRONMENT_FILE:-$working_dir/.env}"
  module="${API_UVICORN_MODULE:-main:app}"
  host="${API_UPSTREAM_HOST:-127.0.0.1}"
  port="$API_UPSTREAM_PORT"
  description="${API_SERVICE_DESCRIPTION:-${APP_NAME} API FastAPI}"

  cat > "$LOCAL_SYSTEMD_DIR/$service" <<EOF_API
[Unit]
Description=$description
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${SYSTEMD_USER:-$REMOTE_USER}
Group=${SYSTEMD_GROUP:-${SYSTEMD_USER:-$REMOTE_USER}}
WorkingDirectory=$working_dir
EnvironmentFile=$env_file
ExecStart=$working_dir/.venv/bin/uvicorn $module --host $host --port $port --workers ${API_WORKERS:-2}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF_API

  echo "GERADO: server/etc/systemd/system/$service"
}

generate_web_service() {
  local service="$1"
  local prefix app_dir working_dir env_file host port description api_service

  : "${WEB_UPSTREAM_PORT:?Defina WEB_UPSTREAM_PORT para gerar automaticamente $service}"

  prefix="$(service_prefix "$service")"
  app_dir="$REMOTE_APP_DIR"
  working_dir="${WEB_WORKING_DIRECTORY:-$app_dir/apps/web}"
  env_file="${WEB_ENVIRONMENT_FILE:-$working_dir/.env}"
  host="${WEB_UPSTREAM_HOST:-127.0.0.1}"
  port="$WEB_UPSTREAM_PORT"
  description="${WEB_SERVICE_DESCRIPTION:-${APP_NAME} Astro Web}"
  api_service="${WEB_AFTER_SERVICE:-$prefix-api.service}"

  cat > "$LOCAL_SYSTEMD_DIR/$service" <<EOF_WEB
[Unit]
Description=$description
After=network-online.target $api_service
Wants=network-online.target

[Service]
Type=simple
User=${SYSTEMD_USER:-$REMOTE_USER}
Group=${SYSTEMD_GROUP:-${SYSTEMD_USER:-$REMOTE_USER}}
WorkingDirectory=$working_dir
EnvironmentFile=$env_file
Environment=NODE_ENV=production
Environment=HOST=$host
Environment=PORT=$port
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
  [[ -f "$LOCAL_SYSTEMD_DIR/$service" ]] && return 0

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
    echo "ERRO: arquivo vazio ou inválido: $LOCAL_SYSTEMD_DIR/$service" >&2
    exit 1
  }
done

echo "Serviços que serão instalados e habilitados: ${SYSTEMD_SERVICES[*]}"
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
