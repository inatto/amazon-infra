#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT/apps/api"
rm -rf .venv
python3 -m venv .venv
.venv/bin/pip install -q -r requirements.txt
sudo systemctl restart amazon-infra-monitor-api.service
