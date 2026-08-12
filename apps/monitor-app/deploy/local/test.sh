#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
apps/api/.venv/bin/python -m compileall -q apps/api
(cd apps/api && .venv/bin/python -c 'from main import app')
(cd apps/api && .venv/bin/python - <<'PYTEST'
import json
from pathlib import Path

inventory = json.loads(Path("inventory.json").read_text(encoding="utf-8"))
groups = {group["id"]: group for group in inventory["groups"]}

assert groups["orbital-app"]["domains"] == ["admin.sindicatto.com"]
assert groups["orbital-app"]["urls"] == [{"url": "http://127.0.0.1:8001/api/health", "role": "API Health"}]
assert "orbital-app-system-email-worker.service" in groups["orbital-app"]["services"]
assert groups["station-app"]["urls"] == [{"url": "http://127.0.0.1:8002/health", "role": "API Health"}]
assert groups["inst-app"]["urls"] == [{"url": "http://127.0.0.1:8003/health", "role": "API Health"}]
assert groups["inst-app"]["services"] == ["inst-app-api.service", "inst-app-web.service"]
assert groups["asaclub-app"]["urls"] == [{"url": "http://127.0.0.1:8004/health", "role": "API Health"}]
assert groups["asaclub-app"]["services"] == ["asaclub-app-api.service", "asaclub-app-web.service"]
module_ports = {item["port"] for item in groups["orbital-modules"]["ports"]}
assert 4109 not in module_ports and 8109 not in module_ports
assert {4111, 8111, 4112, 8112}.issubset(module_ports)
PYTEST
)
grep -Fxq 'APP_CORS_ORIGINS=https://monitor.amazon-infra.localhost' apps/api/config/local/app.env
(cd apps/web && npm run build)
echo "OK: monitor-app v$(cat VERSION) validado."
