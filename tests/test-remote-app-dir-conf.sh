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
! grep -q '^SYSTEMD_SERVICES=' "$CONFIG" || fail 'configuração ainda declara SYSTEMD_SERVICES'

echo 'OK: nome, caminho e portas do módulo content são inferidos sem acoplamento a systemd.'
