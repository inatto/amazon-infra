#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"

remote "sudo ss -ltnp | grep -E ':(80|443|4001|8001|4321|3126|8000|3000|3001|5173) ' || true"
