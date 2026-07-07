#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"
URLS=("$@")
if [[ ${#URLS[@]} -eq 0 ]]; then
  echo "Quais URLs quer testar?"
  echo "Exemplos:"
  echo "  https://admin.sindicatto.com https://api.sindicatto.com"
  echo "  https://sindicatto.com https://sinproprev.org.br"
  read -r -a URLS
fi
if [[ ${#URLS[@]} -eq 0 ]]; then
  URLS=("https://admin.sindicatto.com" "https://api.sindicatto.com" "https://sindicatto.com" "https://sinproprev.org.br")
fi
for url in "${URLS[@]}"; do
  echo "=== $url ==="
  curl -I -L --max-time 15 "$url" || true
  echo ""
done
