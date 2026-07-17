#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
set -Eeuo pipefail

DOMAIN_CONFIG="${1:-}"
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/_load-config.sh"

[[ -f "$LOCAL_SITE_FILE" ]] || {
  echo "ERRO: configuração não encontrada no espelho local:" >&2
  echo "$LOCAL_SITE_FILE" >&2
  exit 1
}

echo "Configuração local que será restaurada:"
echo "$LOCAL_SITE_FILE"
echo
sed -n '1,240p' "$LOCAL_SITE_FILE"
echo
read -r -p "Digite RESTAURAR para enviar esta versão de $SITE_NAME: " confirmation
[[ "$confirmation" == "RESTAURAR" ]] || {
  echo "Restauração cancelada."
  exit 1
}

remote_tmp="/tmp/${SITE_NAME}.restore.$$"
trap 'remote "rm -f '\''$remote_tmp'\''" >/dev/null 2>&1 || true' EXIT

scp "${SSH_OPTIONS[@]}" "$LOCAL_SITE_FILE" "$REMOTE_USER@$REMOTE_HOST:$remote_tmp" >/dev/null
remote "sudo install -m 0644 '$remote_tmp' '$REMOTE_AVAILABLE/$SITE_NAME'"

if [[ -e "$LOCAL_NGINX_PATH/sites-enabled/$SITE_NAME" || -L "$LOCAL_NGINX_PATH/sites-enabled/$SITE_NAME" ]]; then
  remote "sudo ln -sfn '$REMOTE_AVAILABLE/$SITE_NAME' '$REMOTE_ENABLED/$SITE_NAME'"
else
  remote "sudo rm -f '$REMOTE_ENABLED/$SITE_NAME'"
fi

remote "sudo nginx -t && sudo systemctl reload nginx"
echo "OK: configuração de $SITE_NAME restaurada."
