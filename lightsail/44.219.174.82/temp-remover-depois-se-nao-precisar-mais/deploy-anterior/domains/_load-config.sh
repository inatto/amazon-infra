#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains

DOMAIN_DEPLOY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN_CONFIG="${DOMAIN_CONFIG:-$DOMAIN_DEPLOY_DIR/configs/orbital.anpprev.org.conf}"

[[ -f "$DOMAIN_CONFIG" ]] || {
  echo "ERRO: configuração não encontrada: $DOMAIN_CONFIG" >&2
  exit 1
}

# shellcheck source=/dev/null
source "$DOMAIN_CONFIG"

: "${REMOTE_USER:?Defina REMOTE_USER}"
: "${REMOTE_HOST:?Defina REMOTE_HOST}"
: "${SSH_KEY:?Defina SSH_KEY}"
: "${SITE_NAME:?Defina SITE_NAME}"
: "${APP_NAME:?Defina APP_NAME}"
: "${WEB_UPSTREAM_HOST:?Defina WEB_UPSTREAM_HOST}"
: "${WEB_UPSTREAM_PORT:?Defina WEB_UPSTREAM_PORT}"
: "${SSL_EMAIL:?Defina SSL_EMAIL}"
: "${LOCAL_SERVER_DIR:?Defina LOCAL_SERVER_DIR}"

[[ -f "$SSH_KEY" ]] || {
  echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2
  exit 1
}
[[ ${#DOMAINS[@]} -gt 0 ]] || {
  echo "ERRO: informe ao menos um domínio em DOMAINS" >&2
  exit 1
}
[[ "$WEB_UPSTREAM_PORT" =~ ^[0-9]+$ ]] || {
  echo "ERRO: WEB_UPSTREAM_PORT inválida" >&2
  exit 1
}
if [[ -n "${API_UPSTREAM_PORT:-}" && ! "$API_UPSTREAM_PORT" =~ ^[0-9]+$ ]]; then
  echo "ERRO: API_UPSTREAM_PORT inválida" >&2
  exit 1
fi

PRIMARY_DOMAIN="${DOMAINS[0]}"
DOMAIN_LIST="${DOMAINS[*]}"
LOCAL_SERVER_PATH="$(cd "$DOMAIN_DEPLOY_DIR" && realpath -m "$LOCAL_SERVER_DIR")"
LOCAL_NGINX_PATH="$LOCAL_SERVER_PATH/etc/nginx"
LOCAL_SITE_FILE="$LOCAL_NGINX_PATH/sites-available/$SITE_NAME"
REMOTE_AVAILABLE="/etc/nginx/sites-available"
REMOTE_ENABLED="/etc/nginx/sites-enabled"

SSH_OPTIONS=(
  -i "$SSH_KEY"
  -o BatchMode=yes
  -o ConnectTimeout=15
  -o ServerAliveInterval=30
  -o ServerAliveCountMax=6
)

remote() {
  ssh "${SSH_OPTIONS[@]}" "$REMOTE_USER@$REMOTE_HOST" "$@"
}

require_command() {
  command -v "$1" >/dev/null || {
    echo "ERRO: comando não encontrado: $1" >&2
    exit 1
  }
}

validate_domain() {
  [[ "$1" =~ ^([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$ ]] || {
    echo "ERRO: domínio inválido: $1" >&2
    exit 1
  }
}

for domain in "${DOMAINS[@]}"; do
  validate_domain "$domain"
done
