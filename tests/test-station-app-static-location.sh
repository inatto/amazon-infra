#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/ec2/52.67.135.170/domains/painel.anpprev.org.conf"
NGINX_SCRIPT="$ROOT/deploy/02-configurar-nginx.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "ERRO: $*" >&2
  exit 1
}

bash -n "$CONFIG"
bash -n "$NGINX_SCRIPT"

# shellcheck source=/dev/null
source "$CONFIG"
[[ "$SITE_NAME" == 'painel.anpprev.org' ]] || fail "SITE_NAME inesperado: $SITE_NAME"
[[ "$APP_NAME" == 'station-app' ]] || fail "APP_NAME inesperado: $APP_NAME"
[[ "$REMOTE_APP_DIR" == '/home/ubuntu/Code/orgs/station-app' ]] \
  || fail "REMOTE_APP_DIR inesperado: $REMOTE_APP_DIR"
[[ ${#STATIC_LOCATIONS[@]} -eq 1 ]] || fail 'Station deve declarar exatamente uma STATIC_LOCATION'
[[ "${STATIC_LOCATIONS[0]}" == '/tenants/|/home/ubuntu/storage/tenants/' ]] \
  || fail "STATIC_LOCATIONS inesperado: ${STATIC_LOCATIONS[*]}"
! grep -Fq '"/storage/|' "$CONFIG" || fail 'não deve existir rota pública /storage/'

# O deploy deve continuar genérico, sem lógica específica para Station.
grep -Fq 'if declare -p STATIC_LOCATIONS >/dev/null 2>&1; then' "$NGINX_SCRIPT" \
  || fail 'deploy não usa STATIC_LOCATIONS genericamente'
grep -Fq 'location ^~ $public_path {' "$NGINX_SCRIPT" \
  || fail 'deploy não gera location estática genérica'
grep -Fq 'alias $physical_path;' "$NGINX_SCRIPT" \
  || fail 'deploy não gera alias estático genérico'
! grep -Fq 'station-app' "$NGINX_SCRIPT" || fail 'deploy ganhou acoplamento indevido ao station-app'

# Executa o gerador Nginx com ssh/scp mockados e verifica a configuração efetivamente gerada.
mkdir -p "$TMP/bin"
: > "$TMP/key.pem"
cat > "$TMP/bin/ssh" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
cat > "$TMP/bin/scp" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
chmod +x "$TMP/bin/ssh" "$TMP/bin/scp"

TMP_CONFIG="$TMP/painel.anpprev.org.conf"
sed "s#^SSH_KEY=.*#SSH_KEY=\"$TMP/key.pem\"#" "$CONFIG" > "$TMP_CONFIG"
OUTPUT="$(printf 'PUBLICAR\n' | PATH="$TMP/bin:$PATH" "$NGINX_SCRIPT" "$TMP_CONFIG")"

grep -Fq 'server_name painel.anpprev.org;' <<< "$OUTPUT" \
  || fail 'Nginx gerado não contém painel.anpprev.org'
grep -Fq '    location ^~ /tenants/ {' <<< "$OUTPUT" \
  || fail 'Nginx gerado não contém location /tenants/'
grep -Fq '        alias /home/ubuntu/storage/tenants/;' <<< "$OUTPUT" \
  || fail 'Nginx gerado não contém alias de /tenants/'
! grep -Fq '    location ^~ /storage/ {' <<< "$OUTPUT" \
  || fail 'Nginx gerado criou rota pública /storage/'

printf '%s\n' 'OK: painel.anpprev.org publica /tenants/ via storage e usa o caminho correto do station-app.'
