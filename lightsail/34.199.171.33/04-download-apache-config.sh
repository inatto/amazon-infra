#!/usr/bin/env bash
# cd ~/Code/sind-infra/sind-amazon/lightsail/34.199.171.33/
set -euo pipefail

REMOTE_USER="bitnami"
REMOTE_HOST="34.199.171.33"
SSH_KEY="/home/daniel/amazon.ssh"

REMOTE_DIR="/opt/bitnami/apache/"
LOCAL_DIR="$(pwd)/server/opt/bitnami/apache/"
SSH_OPTS="-i $SSH_KEY -o ServerAliveInterval=30 -o ServerAliveCountMax=120 -o TCPKeepAlive=yes"

# Cria a pasta local que receberá somente as configurações do Apache.
mkdir -p "$LOCAL_DIR"

echo "Baixando configurações do Apache Bitnami..."
echo "Origem:  $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
echo "Destino: $LOCAL_DIR"
echo ""

# Mantém a estrutura de diretórios e baixa somente arquivos de configuração.
# Certificados, chaves, logs, binários, aplicações e demais arquivos são ignorados.
rsync -avz --progress \
  --no-owner \
  --no-group \
  --prune-empty-dirs \
  --include='*/' \
  --include='*.conf' \
  --include='*.conf.*' \
  --include='*.include' \
  --include='*.inc' \
  --include='*.load' \
  --include='*.types' \
  --include='mime.types' \
  --include='magic' \
  --include='.htaccess' \
  --exclude='*.key' \
  --exclude='*.crt' \
  --exclude='*.cer' \
  --exclude='*.pem' \
  --exclude='*' \
  --rsync-path='sudo rsync' \
  -e "ssh $SSH_OPTS" \
  "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" \
  "$LOCAL_DIR"

echo ""
echo "Configurações do Apache baixadas com sucesso."
