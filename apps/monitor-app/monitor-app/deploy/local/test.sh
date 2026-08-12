#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
apps/api/.venv/bin/python -m compileall -q apps/api
(cd apps/api && .venv/bin/python -c 'from main import app')
(cd apps/web && npm run build)
echo "OK: monitor-app v$(cat VERSION) validado."
