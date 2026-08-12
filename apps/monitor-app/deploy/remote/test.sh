#!/usr/bin/env bash
set -Eeuo pipefail
curl -fsS http://127.0.0.1:8005/api/health
curl -fsS http://127.0.0.1:4005/ >/dev/null
echo
echo "OK: API e Web disponíveis."
