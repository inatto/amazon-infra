#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

mapfile -d '' FILES < <(find "$ROOT/ec2" "$ROOT/lightsail" "$ROOT/deploy" -type f -print0)
if (( ${#FILES[@]} > 0 )) && grep -IEnH '/home/ubuntu/apps/orbital-[^/[:space:]]*' "${FILES[@]}"; then
  echo 'ERRO: ainda existem caminhos Orbital diretamente em /home/ubuntu/apps.' >&2
  exit 1
fi

while IFS= read -r config; do
  (
    set -Eeuo pipefail
    # shellcheck source=/dev/null
    source "$config"
    [[ "${APP_NAME:-}" == orbital-* ]] || exit 0
    [[ "${REMOTE_APP_DIR:-}" == */"$APP_NAME" ]] || {
      echo "ERRO: caminho Orbital não termina em APP_NAME: $config" >&2
      exit 1
    }
    [[ "$(dirname "$REMOTE_APP_DIR")" == */orbital ]] || {
      echo "ERRO: aplicação Orbital não está em uma pasta-pai orbital: $config" >&2
      exit 1
    }
  )
done < <(find "$ROOT/ec2" "$ROOT/lightsail" -path '*/domains/*.conf' -type f | sort)

grep -qF 'REMOTE_APP_DIR_DEFAULT="/home/$REMOTE_USER/apps/orgs/orbital/$APP_NAME"' \
  "$ROOT/deploy/00-criar-configuracao-dominio.sh" || {
  echo 'ERRO: gerador não possui fallback para a pasta-pai orgs/orbital.' >&2
  exit 1
}

echo 'OK: caminhos orbital-* usam uma pasta-pai orbital e o gerador preserva o padrão atual.'
