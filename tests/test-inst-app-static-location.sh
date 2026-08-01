#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
GENERATOR="$ROOT/deploy/00-criar-configuracao-dominio.sh"
NGINX_SCRIPT="$ROOT/deploy/02-configurar-nginx.sh"

! grep -Fq 'if [[ "$APP_NAME" == '\''inst-app'\'' ]]' "$GENERATOR"
! grep -Fq '/static/inst-app/|/home/$REMOTE_USER/storage/static/inst-app/' "$GENERATOR"
grep -Fq 'location ^~ $public_path {' "$NGINX_SCRIPT"
grep -Fq 'alias $physical_path;' "$NGINX_SCRIPT"

for config in \
  "$ROOT/ec2/52.67.135.170/domains/previa.anpprev.org.conf" \
  "$ROOT/ec2/52.67.135.170/domains/sinproprev.org.br.conf"; do
  bash -n "$config"
  grep -Fq '"/static/inst-app/|/home/ubuntu/storage/static/inst-app/"' "$config"
done

echo 'OK: rota estática vem somente dos arquivos de configuração de domínio.'
