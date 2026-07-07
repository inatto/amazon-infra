#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"
echo "ATENCAO: isso vai parar o Nginx e derrubar sites publicos."
read -r -p "Continuar? Digite SIM: " OK
if [[ "$OK" != "SIM" ]]; then echo "Cancelado."; exit 0; fi
remote "sudo systemctl stop nginx && echo 'OK: nginx parado'"
