#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./01-testar-dns.sh ../domains/<dominio>.conf" >&2
  exit 1
}

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_HOST:?Defina REMOTE_HOST no arquivo do domínio}"
declare -p DOMAINS >/dev/null 2>&1 && (( ${#DOMAINS[@]} > 0 )) || {
  echo "ERRO: defina DOMAINS no arquivo do domínio." >&2
  exit 1
}

for domain in "${DOMAINS[@]}"; do
  ips="$(getent ahostsv4 "$domain" 2>/dev/null | awk '{print $1}' | sort -u || true)"
  [[ -n "$ips" ]] || {
    echo "ERRO: $domain ainda não possui DNS IPv4." >&2
    exit 1
  }

  grep -Fxq "$REMOTE_HOST" <<< "$ips" || {
    echo "ERRO: $domain aponta para: ${ips//$'\n'/, }" >&2
    echo "Esperado: $REMOTE_HOST" >&2
    exit 1
  }

  echo "OK: $domain -> $REMOTE_HOST"
done
