#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CREATOR="$ROOT_DIR/deploy/00-criar-configuracao-dominio.sh"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() {
  echo "ERRO: $*" >&2
  exit 1
}

# O gerador deve oferecer defaults editáveis para nome e caminho remoto.
grep -qF "APP_NAME=\"\$(prompt_default 'Nome da aplicação/processo' \"\$APP_NAME_DEFAULT\")\"" "$CREATOR" \
  || fail 'APP_NAME não usa default editável'
grep -qF "REMOTE_APP_DIR=\"\$(prompt_default 'Diretório remoto completo da aplicação' \"\$REMOTE_APP_DIR_DEFAULT\")\"" "$CREATOR" \
  || fail 'REMOTE_APP_DIR não usa default editável'

# Executa uma cópia isolada para validar o caso real do módulo content.
cp -a "$ROOT_DIR/." "$TMP_ROOT/amazon-infra"
TEST_ROOT="$TMP_ROOT/amazon-infra"
rm -f "$TEST_ROOT/ec2/52.67.135.170/domains/content.anpprev.org.conf"
printf 'content.anpprev.org\n1\n3\n\n\n\n' \
  | "$TEST_ROOT/deploy/00-criar-configuracao-dominio.sh" >/dev/null

CONFIG="$TEST_ROOT/ec2/52.67.135.170/domains/content.anpprev.org.conf"
[[ -s "$CONFIG" ]] || fail 'configuração de teste não foi criada'
# shellcheck source=/dev/null
source "$CONFIG"
[[ "$APP_NAME" == 'orbital-content' ]] || fail "APP_NAME inesperado: $APP_NAME"
[[ "$REMOTE_APP_DIR" == '/home/ubuntu/apps/orgs/orbital/orbital-content' ]] \
  || fail "REMOTE_APP_DIR inesperado: $REMOTE_APP_DIR"
[[ "$WEB_UPSTREAM_PORT" == '4102' ]] || fail "porta web inesperada: $WEB_UPSTREAM_PORT"
[[ "$API_UPSTREAM_PORT" == '8102' ]] || fail "porta API inesperada: $API_UPSTREAM_PORT"
[[ "${SYSTEMD_SERVICES[*]}" == 'orbital-content-api.service orbital-content-web.service' ]] \
  || fail "serviços inesperados: ${SYSTEMD_SERVICES[*]}"

# Instaladores apenas consomem o valor final gravado na configuração.
while IFS= read -r installer; do
  grep -qF ': "${REMOTE_APP_DIR:?Defina REMOTE_APP_DIR em $CONFIG_FILE}"' "$installer" \
    || fail "REMOTE_APP_DIR não é obrigatório em ${installer#$ROOT_DIR/}"
done < <(find "$ROOT_DIR" -path '*/deploy/*instalar-servicos.sh' -type f | sort)

echo 'OK: nome, caminho, portas e serviços do módulo content são inferidos corretamente.'
