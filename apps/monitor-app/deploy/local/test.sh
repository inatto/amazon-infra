#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
apps/api/.venv/bin/python -m compileall -q apps/api
(cd apps/api && .venv/bin/python -c 'from main import app')
(cd apps/api && .venv/bin/python - <<'PY'
import json
from pathlib import Path

inventory = json.loads(Path("inventory.json").read_text(encoding="utf-8"))
station = next(group for group in inventory["groups"] if group["id"] == "station-app")
assert station["urls"] == [{"url": "http://127.0.0.1:8002/health", "role": "API Health"}]
PY
)
(cd apps/web && npm run build)
echo "OK: monitor-app v$(cat VERSION) validado."
