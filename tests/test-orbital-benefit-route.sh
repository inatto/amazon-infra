#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/ec2/52.67.135.170/domains/admin.sindicatto.com.conf"
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

api_route='/orbital-benefit/api/|127.0.0.1|8115|/api/'
web_route='/orbital-benefit/|127.0.0.1|4115'

[[ "$(printf '%s\n' "${API_PROXY_LOCATIONS[@]}" | grep -Fxc "$api_route")" -eq 1 ]] \
  || fail 'rota API do orbital-benefit deve existir exatamente uma vez em 8115'
[[ "$(printf '%s\n' "${WEB_PROXY_LOCATIONS[@]}" | grep -Fxc "$web_route")" -eq 1 ]] \
  || fail 'rota Web do orbital-benefit deve existir exatamente uma vez em 4115'

mkdir -p "$TMP/bin"
: > "$TMP/key.pem"
cat > "$TMP/bin/ssh" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
cat > "$TMP/bin/scp" <<'MOCK'
#!/usr/bin/env bash
set -Eeuo pipefail
src="${@: -2:1}"
cp "$src" "$CAPTURE_PATH"
MOCK
chmod +x "$TMP/bin/ssh" "$TMP/bin/scp"

TMP_CONFIG="$TMP/admin.sindicatto.com.conf"
sed "s#^SSH_KEY=.*#SSH_KEY=\"$TMP/key.pem\"#" "$CONFIG" > "$TMP_CONFIG"
CAPTURE_PATH="$TMP/generated.nginx"
export CAPTURE_PATH
printf 'PUBLICAR\n' | PATH="$TMP/bin:$PATH" "$NGINX_SCRIPT" "$TMP_CONFIG" >/dev/null
[[ -s "$CAPTURE_PATH" ]] || fail 'Nginx gerado não foi capturado'

grep -Fq '    location ^~ /orbital-benefit/api/ {' "$CAPTURE_PATH" \
  || fail 'Nginx gerado não contém a rota API do orbital-benefit'
grep -Fq '        proxy_pass http://127.0.0.1:8115/api/;' "$CAPTURE_PATH" \
  || fail 'Nginx gerado não encaminha a API do orbital-benefit para 8115'
grep -Fq '    location ^~ /orbital-benefit/ {' "$CAPTURE_PATH" \
  || fail 'Nginx gerado não contém a rota Web do orbital-benefit'
grep -Fq '        proxy_pass http://127.0.0.1:4115;' "$CAPTURE_PATH" \
  || fail 'Nginx gerado não encaminha a Web do orbital-benefit para 4115'

printf '%s\n' 'OK: admin.sindicatto.com encaminha orbital-benefit para Web 4115 e API 8115.'
