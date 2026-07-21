#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY="$BASE_DIR/inatto01-sp.pem"
REMOTE_HOST="ubuntu@52.67.135.170"

chmod 400 "$SSH_KEY"

exec ssh \
  -i "$SSH_KEY" \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=120 \
  -o TCPKeepAlive=yes \
  "$REMOTE_HOST"
