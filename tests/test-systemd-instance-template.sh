#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$ROOT_DIR/ec2/52.67.135.170/domains/admin.anpprev.org.conf"
WORKER_FILE="$ROOT_DIR/ec2/52.67.135.170/server/etc/systemd/system/orbital-app-note-worker.service"

[[ -s "$WORKER_FILE" ]] || {
  echo "ERRO: modelo do worker não encontrado na pasta da instância." >&2
  exit 1
}

set +e
OUTPUT="$(cd "$ROOT_DIR/deploy" && printf 'CANCELAR\n' | ./04-instalar-servicos.sh "$CONFIG_FILE" 2>&1)"
STATUS=$?
set -e

[[ $STATUS -ne 0 ]] || {
  echo "ERRO: o teste deveria cancelar antes da instalação remota." >&2
  exit 1
}

[[ "$OUTPUT" == *"Serviços que serão instalados e habilitados:"* ]] || {
  printf '%s\n' "$OUTPUT" >&2
  echo "ERRO: o instalador não chegou à confirmação dos serviços." >&2
  exit 1
}

[[ "$OUTPUT" != *"não existe modelo automático para orbital-app-note-worker.service"* ]] || {
  printf '%s\n' "$OUTPUT" >&2
  echo "ERRO: o instalador ainda ignora o modelo da instância." >&2
  exit 1
}

echo "OK: serviço exclusivo resolvido pela pasta server da instância."
