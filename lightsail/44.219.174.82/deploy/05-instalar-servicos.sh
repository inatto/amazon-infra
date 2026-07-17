#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./05-instalar-servicos.sh ../domains/orbital.anpprev.org.conf" >&2
  exit 1
}

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_USER:?Defina REMOTE_USER}"
: "${REMOTE_HOST:?Defina REMOTE_HOST}"
: "${SSH_KEY:?Defina SSH_KEY}"

if ! declare -p SYSTEMD_SERVICES >/dev/null 2>&1 || [[ ${#SYSTEMD_SERVICES[@]} -eq 0 ]]; then
  echo "Nenhum serviço systemd configurado para este domínio."
  exit 0
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SYSTEMD_DIR="$SCRIPT_DIR/../server/etc/systemd/system"
SSH_OPTIONS=(-i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=15)
remote() { ssh "${SSH_OPTIONS[@]}" "$REMOTE_USER@$REMOTE_HOST" "$@"; }

for service in "${SYSTEMD_SERVICES[@]}"; do
  [[ "$service" =~ ^[A-Za-z0-9_.@-]+\.service$ ]] || { echo "ERRO: serviço inválido: $service" >&2; exit 1; }
  [[ -f "$LOCAL_SYSTEMD_DIR/$service" ]] || { echo "ERRO: arquivo não encontrado: $LOCAL_SYSTEMD_DIR/$service" >&2; exit 1; }
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

