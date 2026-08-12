#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIDS=()
cleanup() {
  ((${#PIDS[@]})) && kill "${PIDS[@]}" 2>/dev/null || true
  wait 2>/dev/null || true
}
trap cleanup INT TERM EXIT

echo "Iniciando Web e API locais. Pressione Ctrl+C para encerrar."
"$SCRIPT_DIR/start-api.sh" & PIDS+=("$!")
"$SCRIPT_DIR/start-web.sh" & PIDS+=("$!")
wait -n "${PIDS[@]}"
