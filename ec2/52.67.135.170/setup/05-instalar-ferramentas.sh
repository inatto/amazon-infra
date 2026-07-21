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
  ca-certificates \
  python3 \
  python3-pip \
  python3-venv \
  nginx \
  certbot \
  python3-certbot-nginx

curl -fsSL https://deb.nodesource.com/setup_22.x \
  | sudo -E bash -

sudo apt install -y \
  nodejs

sudo systemctl enable nginx
sudo systemctl start nginx

REMOTE
