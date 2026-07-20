#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/lightsail/44.194.90.24/setup

set -euo pipefail

SSH_KEY="$HOME/amazon.ssh"
REMOTE_HOST="ubuntu@44.194.90.24"

ssh \
  -i "$SSH_KEY" \
  -o ConnectTimeout=15 \
  "$REMOTE_HOST" \
  'bash -s' <<'REMOTE'

set -euo pipefail

whoami
hostname

cat /etc/os-release

REMOTE
