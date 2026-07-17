#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
set -Eeuo pipefail

DOMAIN_CONFIG="${1:-}"
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/_load-config.sh"

echo "Testando Nginx, certificado e domínio..."
remote "sudo nginx -t && systemctl is-active --quiet nginx"
remote "sudo test -L '$REMOTE_ENABLED/$SITE_NAME'"

for domain in "${DOMAINS[@]}"; do
  received="$(remote "curl -skI --max-time 20 --resolve '$domain:443:127.0.0.1' 'https://$domain/' | tr -d '\r' | awk -F': ' 'tolower(\$1) == \"x-site-app\" {print \$2; exit}'")"
  [[ "$received" == "$APP_NAME" ]] || {
    echo "ERRO: $domain respondeu pela aplicação errada. Esperado $APP_NAME; recebido ${received:-ausente}." >&2
    exit 1
  }
  echo "OK: https://$domain -> X-Site-App: $received"
done

remote "curl --silent --show-error --fail --max-time 15 'http://$WEB_UPSTREAM_HOST:$WEB_UPSTREAM_PORT/' >/dev/null"
echo "OK: upstream web responde em $WEB_UPSTREAM_HOST:$WEB_UPSTREAM_PORT"

if [[ -n "${API_UPSTREAM_PORT:-}" ]]; then
  remote "curl --silent --show-error --fail --max-time 15 'http://${API_UPSTREAM_HOST:-$WEB_UPSTREAM_HOST}:$API_UPSTREAM_PORT/health' >/dev/null"
  echo "OK: upstream API responde em ${API_UPSTREAM_HOST:-$WEB_UPSTREAM_HOST}:$API_UPSTREAM_PORT"
fi
