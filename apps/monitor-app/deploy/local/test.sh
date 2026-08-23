#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
INFRA_ROOT="$(cd "$ROOT/../.." && pwd)"
cd "$ROOT"
apps/api/.venv/bin/python -m compileall -q apps/api
(cd apps/api && .venv/bin/python -c 'from main import app')
(cd apps/api && .venv/bin/python - <<'PYTEST'
import json
from pathlib import Path

inventory = json.loads(Path("inventory.json").read_text(encoding="utf-8"))
groups = {group["id"]: group for group in inventory["groups"]}

orbital = groups["orbital"]
modules = {module["id"]: module for module in orbital["modules"]}
assert orbital["domains"] == ["admin.sindicatto.com"]
assert list(modules) == [
    "orbital-app",
    "orbital-assets",
    "orbital-content",
    "orbital-events",
    "orbital-fin",
    "orbital-mail",
    "orbital-reports",
    "orbital-legal",
    "orbital-ai",
]
assert {item["port"] for item in modules["orbital-events"]["ports"]} == {4104, 8104}
assert any(item["url"].endswith("/api/health/worker") for item in modules["orbital-app"]["urls"])
assert any(item["url"].endswith("/api/health/worker") for item in modules["orbital-mail"]["urls"])

serialized = json.dumps(inventory)
for obsolete_runtime in ("orbital-crm", "orbital-marketing", "orbital-vouchers", "orbital-ui"):
    assert obsolete_runtime not in serialized

assert groups["station-app"]["urls"][0]["url"] == "http://127.0.0.1:8002/health"
assert groups["inst-app"]["urls"][0]["url"] == "http://127.0.0.1:8003/health"
assert groups["asaclub-app"]["urls"][0]["url"] == "http://127.0.0.1:8004/health"
assert groups["amazon-infra"]["modules"][0]["id"] == "amazon-infra-monitor-app"
PYTEST
)
grep -Fxq 'APP_CORS_ORIGINS=https://monitor.amazon-infra.localhost' "$INFRA_ROOT/.config/api/local/app.env"
grep -Fxq 'APP_VERSION=0.0.7' "$INFRA_ROOT/.config/api/local/app.env"
grep -Fxq 'SSO_REDIRECT_URI=https://monitor.inatto.com/auth/callback' "$INFRA_ROOT/.config/api/production/app.env"
grep -Fxq 'APP_CORS_ORIGINS=https://monitor.inatto.com' "$INFRA_ROOT/.config/api/production/app.env"
grep -Fq "return Astro.redirect(`${apiUrl}/api/auth/login`, 302);" apps/web/src/pages/index.astro
grep -Fq 'SESSION_COOKIE = "monitor_session_v2"' apps/api/auth.py
(cd apps/api && .venv/bin/python - <<'PYAUTH'
from auth import _decode_session, _encode_session
from settings import get_settings

settings = get_settings()
identity = {
    "person_id": 1,
    "member_id": 1,
    "name": "Dev",
    "login": "dev",
    "tenant_code": "sindicatto",
    "etype_code": "admin",
    "profile_name": "Admin",
    "company_name": "Sindicatto",
    "is_admin": True,
    "is_dev": True,
}
token = _encode_session(identity, settings)
assert _decode_session(token, settings) == identity
assert _decode_session(token + "x", settings) is None
PYAUTH
)
(cd apps/web && npm run build)
echo "OK: monitor-app v$(cat VERSION) validado."
