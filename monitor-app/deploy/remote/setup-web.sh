#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT/apps/web"
rm -rf node_modules dist .astro
npm ci
npm run build
sudo systemctl restart amazon-infra-monitor-web.service
