#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/lightsail/44.194.90.24/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./01-testar-dns.sh ../domains/orbital.anpprev.org.conf" >&2
  exit 1
}

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_HOST:?Defina REMOTE_HOST no arquivo do domínio}"
[[ ${#DOMAINS[@]} -gt 0 ]] || { echo "ERRO: informe DOMAINS." >&2; exit 1; }

for domain in "${DOMAINS[@]}"; do
  ips="$({ getent ahostsv4 "$domain" 2>/dev/null || true; } | awk '{print $1}' | sort -u)"
  [[ -n "$ips" ]] || { echo "ERRO: $domain ainda não possui DNS IPv4." >&2; exit 1; }
  grep -Fxq "$REMOTE_HOST" <<< "$ips" || {
    echo "ERRO: $domain aponta para: $ips" >&2
    echo "Esperado: $REMOTE_HOST" >&2
    exit 1
  }
  echo "OK: $domain -> $REMOTE_HOST"
done
