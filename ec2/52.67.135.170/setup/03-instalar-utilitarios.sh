#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/setup

set -euo pipefail

SSH_KEY="$HOME/amazon.ssh"
REMOTE_HOST="ubuntu@52.67.135.170"

ssh \
  -i "$SSH_KEY" \
  -o ConnectTimeout=15 \
  "$REMOTE_HOST" \
  'bash -s' <<'REMOTE'

set -euo pipefail

sudo apt install -y \
  curl \
  git \
  rsync \
  unzip

REMOTE
