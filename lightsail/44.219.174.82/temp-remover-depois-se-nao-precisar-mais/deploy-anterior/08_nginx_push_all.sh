#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"

echo "ATENCAO: isso envia TODOS os arquivos de server/etc/nginx para /etc/nginx no servidor."
read -r -p "Continuar? Digite SIM: " OK
if [[ "$OK" != "SIM" ]]; then echo "Cancelado."; exit 0; fi
rsync -avz --delete -e "ssh -i $SSH_KEY" "$LOCAL_SERVER_ABS/etc/nginx/" "$REMOTE_USER@$REMOTE_HOST:/tmp/nginx-full/"
remote "sudo rsync -a --delete /tmp/nginx-full/ /etc/nginx/ && sudo nginx -t && sudo systemctl reload nginx"
echo "OK: Nginx completo enviado."
