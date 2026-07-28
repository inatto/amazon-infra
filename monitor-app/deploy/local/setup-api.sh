#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT/apps/api"
python3 -m venv .venv
.venv/bin/pip install -q -r requirements.txt
[[ -f .env ]] || cp .env.example .env
