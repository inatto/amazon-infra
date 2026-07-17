#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"

SITE="${1:-}"
if [[ -z "$SITE" ]]; then
  echo "Qual site Nginx voce quer enviar?"
  echo "Exemplos:"
  echo "  admin.sindicatto.com"
  echo "  api.sindicatto.com"
  echo "  sindicatto.com"
  echo "  sinproprev.org.br"
  echo ""
  echo "Arquivos disponiveis:"
  find "$LOCAL_SERVER_ABS/etc/nginx/sites-available" -maxdepth 1 -type f -printf '  %f\n' | sort
  read -r -p "> " SITE
fi

if [[ -z "$SITE" ]]; then echo "ERRO: site vazio"; exit 1; fi
LOCAL_FILE="$LOCAL_SERVER_ABS/etc/nginx/sites-available/$SITE"
if [[ ! -f "$LOCAL_FILE" ]]; then
  echo "ERRO: arquivo nao existe: $LOCAL_FILE"
  exit 1
fi

echo "Enviando $SITE para $REMOTE_USER@$REMOTE_HOST:$REMOTE_NGINX_AVAILABLE/$SITE"
rsync -avz -e "ssh -i $SSH_KEY" "$LOCAL_FILE" "$REMOTE_USER@$REMOTE_HOST:/tmp/$SITE"
remote "sudo cp '/tmp/$SITE' '$REMOTE_NGINX_AVAILABLE/$SITE' && sudo nginx -t && sudo systemctl reload nginx"
echo "OK: $SITE enviado e Nginx recarregado."
