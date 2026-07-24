#!/usr/bin/env bash
# cd ~/Code/sind-infra/sind-amazon/lightsail/34.199.171.33/
set -euo pipefail

REMOTE_USER="bitnami"
REMOTE_HOST="34.199.171.33"
SSH_KEY="/home/daniel/amazon.ssh"
LOCAL_FILE="server/opt/bitnami/apache/conf/vhosts/farm.inatto.com-vhost.conf"
REMOTE_DIR="/opt/bitnami/apache/conf/vhosts"
REMOTE_FILE="$REMOTE_DIR/farm.inatto.com-vhost.conf"
SSH_OPTS=(-i "$SSH_KEY" -o ServerAliveInterval=30 -o ServerAliveCountMax=120 -o TCPKeepAlive=yes)

if [[ ! -f "$LOCAL_FILE" ]]; then
  echo "Arquivo local não encontrado: $LOCAL_FILE" >&2
  exit 1
fi

ssh "${SSH_OPTS[@]}" "$REMOTE_USER@$REMOTE_HOST" \
  'test -d /home/intcom/farm.inatto.com'

scp "${SSH_OPTS[@]}" "$LOCAL_FILE" "$REMOTE_USER@$REMOTE_HOST:/tmp/farm.inatto.com-vhost.conf"

ssh "${SSH_OPTS[@]}" "$REMOTE_USER@$REMOTE_HOST" "
  set -euo pipefail

  if [[ -f '$REMOTE_FILE' ]]; then
    sudo cp '$REMOTE_FILE' '$REMOTE_FILE.back.\$(date +%Y%m%d%H%M%S)'
  fi

  sudo install -o root -g root -m 0644 \
    /tmp/farm.inatto.com-vhost.conf \
    '$REMOTE_FILE'

  rm -f /tmp/farm.inatto.com-vhost.conf

  sudo /opt/bitnami/apache/bin/apachectl -t
  sudo /opt/bitnami/ctlscript.sh restart apache
  sudo /opt/bitnami/apache/bin/httpd -S
"
