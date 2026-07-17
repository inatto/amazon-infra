#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
set -Eeuo pipefail

DOMAIN_CONFIG="${1:-}"
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/_load-config.sh"

require_command getent

echo "Verificando DNS para o servidor $REMOTE_HOST..."

for domain in "${DOMAINS[@]}"; do
  resolved="$(getent ahostsv4 "$domain" 2>/dev/null | awk '{print $1}' | sort -u | paste -sd, - || true)"

  if [[ -z "$resolved" ]]; then
    echo "ERRO: $domain ainda não possui resolução IPv4 pública." >&2
    exit 1
  fi

  if [[ ",$resolved," != *",$REMOTE_HOST,"* ]]; then
    echo "ERRO: $domain resolve para $resolved; esperado $REMOTE_HOST." >&2
    exit 1
  fi

  echo "OK: $domain -> $REMOTE_HOST"
done
