#!/usr/bin/env bash
# cd ~/Code/sind-infra/sind-amazon/lightsail/34.199.171.33/
set -euo pipefail

REMOTE_USER="bitnami"
REMOTE_HOST="34.199.171.33"
SSH_KEY="/home/daniel/amazon.ssh"

REMOTE_DIR="/home/asaorgbr/"
LOCAL_DIR="/home/daniel/Code/site-old-asaclub/asaorgbr/"
SSH_OPTS="-i $SSH_KEY -o ServerAliveInterval=30 -o ServerAliveCountMax=120 -o TCPKeepAlive=yes"

# Cria a pasta local que receberá os arquivos do servidor.
mkdir -p "$LOCAL_DIR"

echo "Baixando arquivos do ASAClub..."
echo "Origem:  $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
echo "Destino: $LOCAL_DIR"
echo ""

# Baixa por rsync todo o conteúdo de /home/asaorgbr/ para a pasta local.
# A opção --delete não é usada, portanto arquivos locais extras não serão apagados.
rsync -avz --progress \
  --no-owner \
  --no-group \
  -e "ssh $SSH_OPTS" \
  "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" \
  "$LOCAL_DIR"

echo ""
echo "Download concluído."
