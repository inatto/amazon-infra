#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/setup-api.sh"
"$DIR/setup-web.sh"
"$DIR/test.sh"
"$DIR/start.sh"
