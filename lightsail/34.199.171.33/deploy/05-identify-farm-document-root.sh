#!/usr/bin/env bash
# cd ~/Code/sind-infra/sind-amazon/lightsail/34.199.171.33/
set -euo pipefail

REMOTE_USER="bitnami"
REMOTE_HOST="34.199.171.33"
SSH_KEY="/home/daniel/amazon.ssh"
SSH_OPTS="-i $SSH_KEY -o ServerAliveInterval=30 -o ServerAliveCountMax=120 -o TCPKeepAlive=yes"
TARGET_FILE="css/font-awesome/5.7.1.pro/webfonts/fa-regular-400.woff"

ssh $SSH_OPTS "$REMOTE_USER@$REMOTE_HOST" "
  set -euo pipefail

  echo '===== ARQUIVO EXATO ====='
  sudo find /home /opt/bitnami/apache/htdocs \
    -type f \
    -path '*/$TARGET_FILE' \
    -printf '%p\n' \
    2>/dev/null || true

  echo
  echo '===== PASTAS RELACIONADAS A FARM ====='
  sudo find /home /opt/bitnami/apache/htdocs \
    -maxdepth 5 \
    -type d \
    -iname '*farm*' \
    -printf '%p\n' \
    2>/dev/null || true

  echo
  echo '===== REFERÊNCIAS NOS ARQUIVOS DOS SITES ====='
  sudo grep -RIl \
    --exclude='*.log' \
    --exclude='*.gz' \
    --exclude='*.zip' \
    'font-awesome/5.7.1.pro/webfonts/fa-regular-400.woff' \
    /home /opt/bitnami/apache/htdocs \
    2>/dev/null | head -50 || true
"
