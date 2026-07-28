#!/usr/bin/env bash
set -Eeuo pipefail
sudo systemctl restart amazon-infra-monitor-api.service
sudo systemctl status amazon-infra-monitor-api.service --no-pager -l
