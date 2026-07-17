#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
# CONFIG PRINCIPAL DO DEPLOY DO SERVIDOR
# Copie/edite este arquivo se mudar IP, usuario ou chave SSH.

REMOTE_USER="ubuntu"
REMOTE_HOST="44.219.174.82"
SSH_KEY="/home/daniel/amazon.ssh"
REMOTE_NGINX_AVAILABLE="/etc/nginx/sites-available"
REMOTE_NGINX_ENABLED="/etc/nginx/sites-enabled"
LOCAL_SERVER_DIR="../server"

script_dir() {
  local src="${BASH_SOURCE[1]:-${BASH_SOURCE[0]:-$0}}"
  cd -- "$(dirname -- "$src")" && pwd
}

DEPLOY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
ROOT_DIR="$(cd -- "$DEPLOY_DIR/.." && pwd)"
LOCAL_SERVER_ABS="$ROOT_DIR/server"

ssh_base() {
  ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" "$@"
}

remote() {
  ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" "$@"
}

rsync_base() {
  rsync -avz --delete -e "ssh -i $SSH_KEY" "$@"
}

ask_value() {
  local var_name="$1"
  local label="$2"
  local example="$3"
  local value="${!var_name:-}"
  if [[ -z "$value" ]]; then
    echo "$label"
    echo "Exemplo: $example"
    read -r -p "> " value
  fi
  if [[ -z "$value" ]]; then
    echo "ERRO: valor vazio. Abortando."
    exit 1
  fi
  printf -v "$var_name" '%s' "$value"
}
