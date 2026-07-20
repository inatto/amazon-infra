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

python3 --version
pip3 --version

python3 -m venv --help \
  >/dev/null

echo "python3-venv: OK"

node --version
npm --version

nginx -v
certbot --version

sudo nginx -t
sudo systemctl is-enabled nginx
sudo systemctl is-active nginx

systemctl --version \
  | head -n 1

REMOTE
