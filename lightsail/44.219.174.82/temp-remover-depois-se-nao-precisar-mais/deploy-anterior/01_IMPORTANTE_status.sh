#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"

echo "Servidor: $REMOTE_USER@$REMOTE_HOST"
echo ""
remote "
  set -e
  echo '=== HOST ==='
  hostname
  uptime -p
  echo ''
  echo '=== DISCO ==='
  df -h /
  echo ''
  echo '=== MEMORIA ==='
  free -h
  echo ''
  echo '=== NGINX ==='
  systemctl is-active nginx || true
  sudo nginx -t || true
  echo ''
  echo '=== PORTAS ==='
  sudo ss -ltnp | grep -E ':(80|443|4001|8001|4321|3126|8000|3000|3001|5173) ' || true
  echo ''
  echo '=== PM2 ==='
  if command -v pm2 >/dev/null 2>&1; then pm2 list; else echo 'pm2 nao instalado'; fi
  echo ''
  echo '=== SERVICOS SYSTEMD ==='
  systemctl --no-pager --lines=5 status orbital-api.service orbital-web.service || true
  systemctl --no-pager --lines=5 status sindicatto-api.service || true
"
