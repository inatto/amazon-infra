#!/usr/bin/env bash
set -Eeuo pipefail
echo "Iniciando Amazon Infra Monitor API."
sudo systemctl restart amazon-infra-monitor-api.service
for _ in {1..20}; do
  if curl -fsS http://127.0.0.1:8005/api/health >/dev/null; then
    echo "OK: API disponível em 127.0.0.1:8005."
    exit 0
  fi
  sleep 1
done
sudo systemctl status amazon-infra-monitor-api.service --no-pager -l || true
exit 1
