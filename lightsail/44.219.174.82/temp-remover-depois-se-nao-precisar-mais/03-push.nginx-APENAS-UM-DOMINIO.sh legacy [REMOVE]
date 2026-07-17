#!/usr/bin/env bash
# DESATIVADO: hardcoded para admin.sindicatto.com e substituído pelo publicador seguro.
set -e

REMOTE_USER="ubuntu"
REMOTE_HOST="44.219.174.82"
SSH_KEY="/home/daniel/amazon.ssh"

#deve ser relativo a este arquivo
LOCAL_NGINX_DIR="/home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/server/etc/nginx"
#SITE_NAME="sinproprev.sindicatto.com"
#SITE_NAME="sinproprev.org.br"
SITE_NAME="admin.sindicatto.com"
SSH_OPTS="-i $SSH_KEY -o ServerAliveInterval=30 -o ServerAliveCountMax=120 -o TCPKeepAlive=yes"

LOCAL_SITE_FILE="$LOCAL_NGINX_DIR/sites-available/$SITE_NAME"

if [ ! -f "$LOCAL_SITE_FILE" ]; then
  echo "Arquivo local não encontrado:"
  echo "$LOCAL_SITE_FILE"
  exit 1
fi

echo "Enviando configuração Nginx:"
echo "$LOCAL_SITE_FILE"
echo ""

rsync -avz \
  --no-owner \
  --no-group \
  -e "ssh $SSH_OPTS" \
  --rsync-path="sudo rsync" \
  "$LOCAL_SITE_FILE" \
  "$REMOTE_USER@$REMOTE_HOST:/etc/nginx/sites-available/$SITE_NAME"

echo ""
echo "Ativando site no Nginx remoto..."

ssh $SSH_OPTS "$REMOTE_USER@$REMOTE_HOST" "
  set -e
  sudo ln -sf /etc/nginx/sites-available/$SITE_NAME /etc/nginx/sites-enabled/$SITE_NAME
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
echo "Nginx atualizado com sucesso."
