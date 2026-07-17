#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -e

REMOTE_USER="ubuntu"
REMOTE_HOST="44.219.174.82"
SSH_KEY="/home/daniel/amazon.ssh"

LOCAL_NGINX_DIR="/home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/server/etc/nginx"
SSH_OPTS="-i $SSH_KEY -o ServerAliveInterval=30 -o ServerAliveCountMax=120 -o TCPKeepAlive=yes"

LOCAL_FILE="$LOCAL_NGINX_DIR/nginx.conf"
REMOTE_FILE="/etc/nginx/nginx.conf"

if [ ! -f "$LOCAL_FILE" ]; then
  echo "Arquivo local não encontrado:"
  echo "$LOCAL_FILE"
  exit 1
fi

echo "Enviando nginx.conf:"
echo "$LOCAL_FILE -> $REMOTE_USER@$REMOTE_HOST:$REMOTE_FILE"
echo ""

rsync -avz \
  --no-owner \
  --no-group \
  -e "ssh $SSH_OPTS" \
  --rsync-path="sudo rsync" \
  "$LOCAL_FILE" \
  "$REMOTE_USER@$REMOTE_HOST:$REMOTE_FILE"

echo ""
echo "Garantindo pasta de cache..."

ssh $SSH_OPTS "$REMOTE_USER@$REMOTE_HOST" "
  set -e
  sudo mkdir -p /var/cache/nginx/astro
  sudo chown -R www-data:www-data /var/cache/nginx/astro
"

echo ""
echo "Testando Nginx remoto..."

ssh $SSH_OPTS "$REMOTE_USER@$REMOTE_HOST" "
  set -e
  sudo nginx -t
"

echo ""
echo "Recarregando Nginx remoto..."

ssh $SSH_OPTS "$REMOTE_USER@$REMOTE_HOST" "
  set -e
  sudo systemctl reload nginx
"

echo ""
echo "nginx.conf atualizado com sucesso."
