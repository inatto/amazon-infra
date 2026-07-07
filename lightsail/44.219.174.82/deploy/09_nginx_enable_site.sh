#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"
SITE="${1:-}"
if [[ -z "$SITE" ]]; then
  echo "Qual site quer habilitar?"
  echo "Exemplo: admin.sindicatto.com"
  read -r -p "> " SITE
fi
[[ -n "$SITE" ]] || { echo "ERRO: site vazio"; exit 1; }
remote "sudo ln -sfn '$REMOTE_NGINX_AVAILABLE/$SITE' '$REMOTE_NGINX_ENABLED/$SITE' && sudo nginx -t && sudo systemctl reload nginx"
echo "OK: site habilitado: $SITE"
