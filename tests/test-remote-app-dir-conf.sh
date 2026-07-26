#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "ERRO: $*" >&2
  exit 1
}

# O gerador deve pedir o caminho completo, sem reconhecer famílias de projeto.
creator="$ROOT_DIR/deploy/00-criar-configuracao-dominio.sh"
grep -qF "REMOTE_APP_DIR=\"\$(prompt_required 'Diretório remoto completo da aplicação')\"" "$creator" \
  || fail 'o gerador não exige REMOTE_APP_DIR explicitamente'
! grep -Eq 'APP_NAME.*orbital|orbital-\*|REMOTE_APP_DIR_DEFAULT|apps/orbital/\$APP_NAME' "$creator" \
  || fail 'o gerador ainda contém convenção de caminho por aplicação'

# Instaladores podem apenas consumir REMOTE_APP_DIR; nunca inventar /home/.../apps.
while IFS= read -r installer; do
  grep -qF ': "${REMOTE_APP_DIR:?Defina REMOTE_APP_DIR em $CONFIG_FILE}"' "$installer" \
    || fail "REMOTE_APP_DIR não é obrigatório em ${installer#$ROOT_DIR/}"
  ! grep -Eq 'REMOTE_APP_DIR:-|/home/.*/apps/\$APP_NAME|apps/orbital/\$APP_NAME' "$installer" \
    || fail "há fallback de caminho em ${installer#$ROOT_DIR/}"
done < <(find "$ROOT_DIR" -path '*/deploy/*instalar-servicos.sh' -type f | sort)

# Todo domínio que instala serviços deve declarar um caminho remoto absoluto.
while IFS= read -r config; do
  (
    set -Eeuo pipefail
    # shellcheck disable=SC1090
    source "$config"
    if declare -p SYSTEMD_SERVICES >/dev/null 2>&1 && (( ${#SYSTEMD_SERVICES[@]} > 0 )); then
      [[ -n "${REMOTE_APP_DIR:-}" ]] \
        || fail "REMOTE_APP_DIR ausente em ${config#$ROOT_DIR/}"
      [[ "$REMOTE_APP_DIR" == /* && "$REMOTE_APP_DIR" != *'..'* ]] \
        || fail "REMOTE_APP_DIR inválido em ${config#$ROOT_DIR/}: $REMOTE_APP_DIR"
    fi
  )
done < <(find "$ROOT_DIR/ec2" "$ROOT_DIR/lightsail" -path '*/domains/*.conf' -type f | sort)

# A organização orbital pertence somente aos dados de configuração.
while IFS= read -r config; do
  (
    set -Eeuo pipefail
    # shellcheck disable=SC1090
    source "$config"
    [[ "${APP_NAME:-}" == orbital-* ]] || exit 0
    [[ "$REMOTE_APP_DIR" == "/home/$REMOTE_USER/apps/orbital/$APP_NAME" ]] \
      || fail "caminho orbital incorreto em ${config#$ROOT_DIR/}: $REMOTE_APP_DIR"
  )
done < <(find "$ROOT_DIR/ec2" "$ROOT_DIR/lightsail" -path '*/domains/*.conf' -type f | sort)

echo 'OK: REMOTE_APP_DIR vem exclusivamente dos arquivos domains/*.conf.'
