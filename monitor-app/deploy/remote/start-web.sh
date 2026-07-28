#!/usr/bin/env bash
set -Eeuo pipefail
sudo systemctl restart amazon-infra-monitor-web.service
sudo systemctl status amazon-infra-monitor-web.service --no-pager -l
