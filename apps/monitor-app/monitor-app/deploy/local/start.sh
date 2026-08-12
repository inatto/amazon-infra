#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
trap 'kill 0 2>/dev/null || true' INT TERM EXIT
"$DIR/start-api.sh" &
"$DIR/start-web.sh" &
wait
