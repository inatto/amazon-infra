#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT/apps/api"
exec .venv/bin/uvicorn main:app --host 127.0.0.1 --port 8005
