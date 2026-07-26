#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OLD_PREFIX='/home/ubuntu/apps/'"orbital-"
EXPECTED_PREFIX='/home/ubuntu/apps/orbital/'"orbital-"

mapfile -d '' FILES < <(find "$ROOT" -type f -print0)
if (( ${#FILES[@]} > 0 )) && grep -IEnH "$OLD_PREFIX" "${FILES[@]}"; then
  echo "ERRO: ainda existem caminhos Orbital sem a pasta-pai /orbital." >&2
  exit 1
fi

for config in \
  "$ROOT/ec2/52.67.135.170/domains/admin.anpprev.org.conf" \
  "$ROOT/lightsail/44.194.90.24/domains/orbital.anpprev.org.conf" \
  "$ROOT/lightsail/44.219.174.82/domains/orbital.anpprev.org.conf"; do
  # shellcheck source=/dev/null
  source "$config"
  [[ "$APP_NAME" == orbital-* ]] || {
    echo "ERRO: configuração Orbital inválida: $config" >&2
    exit 1
  }
  [[ "$REMOTE_APP_DIR" == "/home/$REMOTE_USER/apps/orbital/$APP_NAME" ]] || {
    echo "ERRO: REMOTE_APP_DIR incorreto em $config: $REMOTE_APP_DIR" >&2
    exit 1
  }
done

mapfile -t ORBITAL_SERVICES < <(
  find "$ROOT" -type f -path '*/server/etc/systemd/system/orbital*.service' -print | sort
)
(( ${#ORBITAL_SERVICES[@]} > 0 )) || {
  echo 'ERRO: nenhum serviço Orbital encontrado para validar.' >&2
  exit 1
}

for service in "${ORBITAL_SERVICES[@]}"; do
  grep -qF "$EXPECTED_PREFIX" "$service" || {
    echo "ERRO: serviço sem pasta-pai Orbital: $service" >&2
    exit 1
  }
done

grep -qF 'REMOTE_APP_DIR_DEFAULT="/home/$REMOTE_USER/apps/orbital/$APP_NAME"' \
  "$ROOT/deploy/00-criar-configuracao-dominio.sh" || {
  echo 'ERRO: gerador de domínios não preserva a pasta-pai Orbital.' >&2
  exit 1
}

echo 'OK: todos os caminhos orbital-* usam /home/ubuntu/apps/orbital/orbital-*.'
