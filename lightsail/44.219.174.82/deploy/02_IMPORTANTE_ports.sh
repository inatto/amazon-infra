#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"

remote "sudo ss -ltnp | grep -E ':(80|443|4321|4322|8000|3000|3001|5173) ' || true"
