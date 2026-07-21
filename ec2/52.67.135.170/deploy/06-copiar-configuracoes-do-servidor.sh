#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/deploy

set -Eeuo pipefail

CONFIG_FILE="${1:-}"

[[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./06-copiar-configuracoes-do-servidor.sh ../domains/admin.anpprev.org.conf" >&2
  exit 1
}

# shellcheck source=/dev/null
source "$CONFIG_FILE"

: "${REMOTE_USER:?Defina REMOTE_USER}"
: "${REMOTE_HOST:?Defina REMOTE_HOST}"
: "${SSH_KEY:?Defina SSH_KEY}"
: "${SITE_NAME:?Defina SITE_NAME}"
: "${SYSTEMD_SERVICES:?Defina SYSTEMD_SERVICES}"

[[ -f "$SSH_KEY" ]] || {
  echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2
  exit 1
}

command -v rsync >/dev/null || {
  echo "ERRO: rsync não encontrado no WSL." >&2
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SERVER_DIR="$SCRIPT_DIR/../server"
REMOTE_TEMP_DIR="/tmp/amazon-infra-configuracoes"

SSH_OPTIONS=(
  -i "$SSH_KEY"
  -o BatchMode=yes
  -o ConnectTimeout=15
)

SERVICES_TEXT="$(printf '%s\n' "${SYSTEMD_SERVICES[@]}")"

printf '\nCopiando somente as configurações criadas para %s...\n\n' "$SITE_NAME"

ssh \
  "${SSH_OPTIONS[@]}" \
  "$REMOTE_USER@$REMOTE_HOST" \
  "SITE_NAME='$SITE_NAME' REMOTE_TEMP_DIR='$REMOTE_TEMP_DIR' SERVICES_TEXT='$SERVICES_TEXT' bash -s" <<'REMOTE'

set -Eeuo pipefail

sudo rm -rf "$REMOTE_TEMP_DIR"
sudo mkdir -p \
  "$REMOTE_TEMP_DIR/etc/nginx/sites-available" \
  "$REMOTE_TEMP_DIR/etc/systemd/system"

NGINX_SITE="/etc/nginx/sites-available/$SITE_NAME"

if [[ -f "$NGINX_SITE" ]]; then
  sudo cp -a \
    "$NGINX_SITE" \
    "$REMOTE_TEMP_DIR/etc/nginx/sites-available/"
else
  echo "ERRO: configuração Nginx não encontrada: $NGINX_SITE" >&2
  exit 1
fi

while IFS= read -r service; do
  [[ -n "$service" ]] || continue

  SERVICE_FILE="/etc/systemd/system/$service"

  if [[ -f "$SERVICE_FILE" ]]; then
    sudo cp -a \
      "$SERVICE_FILE" \
      "$REMOTE_TEMP_DIR/etc/systemd/system/"
  else
    echo "ERRO: serviço não encontrado: $SERVICE_FILE" >&2
    exit 1
  fi
done <<< "$SERVICES_TEXT"

RENEWAL_FILE="/etc/letsencrypt/renewal/$SITE_NAME.conf"

if [[ -f "$RENEWAL_FILE" ]]; then
  sudo mkdir -p "$REMOTE_TEMP_DIR/etc/letsencrypt/renewal"
  sudo cp -a \
    "$RENEWAL_FILE" \
    "$REMOTE_TEMP_DIR/etc/letsencrypt/renewal/"
fi

sudo chown -R "$USER:$USER" "$REMOTE_TEMP_DIR"

REMOTE

rm -rf "$LOCAL_SERVER_DIR"
mkdir -p "$LOCAL_SERVER_DIR"

rsync \
  -avz \
  --delete \
  --no-owner \
  --no-group \
  -e "ssh -i $SSH_KEY -o BatchMode=yes -o ConnectTimeout=15" \
  "$REMOTE_USER@$REMOTE_HOST:$REMOTE_TEMP_DIR/" \
  "$LOCAL_SERVER_DIR/"

ssh \
  "${SSH_OPTIONS[@]}" \
  "$REMOTE_USER@$REMOTE_HOST" \
  "rm -rf '$REMOTE_TEMP_DIR'"

printf '\nOK: somente os arquivos criados para %s foram copiados para:\n%s\n' \
  "$SITE_NAME" \
  "$LOCAL_SERVER_DIR"
