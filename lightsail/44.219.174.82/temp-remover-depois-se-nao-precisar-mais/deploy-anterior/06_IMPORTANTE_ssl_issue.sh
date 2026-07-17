#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"

DOMAINS=("$@")
if [[ ${#DOMAINS[@]} -eq 0 ]]; then
  echo "Para quais dominios quer emitir SSL?"
  echo "Exemplos:"
  echo "  admin.sindicatto.com"
  echo "  api.sindicatto.com"
  echo "  sindicatto.com www.sindicatto.com"
  echo "  sinproprev.org.br www.sinproprev.org.br"
  echo ""
  echo "Digite um ou mais dominios separados por espaco:"
  read -r -a DOMAINS
fi

if [[ ${#DOMAINS[@]} -eq 0 ]]; then echo "ERRO: nenhum dominio informado"; exit 1; fi

ARGS=""
for d in "${DOMAINS[@]}"; do ARGS="$ARGS -d $d"; done

echo "Emitindo/ajustando SSL para: ${DOMAINS[*]}"
remote "sudo certbot --nginx $ARGS --redirect --agree-tos --no-eff-email -m danielmaiax@gmail.com && sudo nginx -t && sudo systemctl reload nginx"
