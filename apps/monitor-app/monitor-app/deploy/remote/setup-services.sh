#!/usr/bin/env bash
set -Eeuo pipefail

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_UNIT_DIR="${SYSTEMD_UNIT_DIR:-/etc/systemd/system}"
SERVICES=(amazon-infra-monitor-api.service amazon-infra-monitor-web.service)
UPDATED=0

for service in "${SERVICES[@]}"; do
  source_file="$DIR/systemd/$service"
  target_file="$SYSTEMD_UNIT_DIR/$service"
  [[ -f "$source_file" ]] || { echo "ERRO: unit não encontrado: $source_file" >&2; exit 1; }
  if ! sudo cmp -s "$source_file" "$target_file"; then
    UPDATED=1
  fi
  sudo install -m 0644 "$source_file" "$target_file"
done

if (( UPDATED )); then
  sudo systemctl daemon-reload
fi
sudo systemctl enable "${SERVICES[@]}"
