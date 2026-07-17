#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"
remote "
  set -e
  echo 'Limpando cache basico...'
  sudo rm -rf /var/cache/nginx/* 2>/dev/null || true
  pm2 flush 2>/dev/null || true
  sudo journalctl --vacuum-time=7d >/dev/null 2>&1 || true
  sudo systemctl reload nginx || true
  echo 'OK: cache/logs basicos limpos.'
"
