#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
set -Eeuo pipefail

DOMAIN_CONFIG="${1:-}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_load-config.sh"

remote "command -v certbot >/dev/null"

certbot_domains=""
for domain in "${DOMAINS[@]}"; do
  printf -v certbot_domains '%s -d %q' "$certbot_domains" "$domain"
done

echo "Emitindo ou reutilizando o certificado de $PRIMARY_DOMAIN..."
remote "sudo certbot certonly --nginx --non-interactive --agree-tos --no-eff-email --keep-until-expiring --cert-name '$PRIMARY_DOMAIN' -m '$SSL_EMAIL' $certbot_domains"
remote "sudo test -s '/etc/letsencrypt/live/$PRIMARY_DOMAIN/fullchain.pem' && sudo test -s '/etc/letsencrypt/live/$PRIMARY_DOMAIN/privkey.pem'"

echo "Certificado disponível. Publicando a configuração HTTPS definitiva..."
"$SCRIPT_DIR/03-nginx-publish.sh" "$DOMAIN_CONFIG"
