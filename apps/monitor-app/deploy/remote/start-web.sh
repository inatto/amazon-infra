#!/usr/bin/env bash
set -Eeuo pipefail
echo "Iniciando Amazon Infra Monitor Web."
sudo systemctl restart amazon-infra-monitor-web.service
for _ in {1..20}; do
  if curl -fsS http://127.0.0.1:4005/ >/dev/null; then
    echo "OK: Web disponível em 127.0.0.1:4005."
    exit 0
  fi
  sleep 1
done
sudo systemctl status amazon-infra-monitor-web.service --no-pager -l || true
exit 1
