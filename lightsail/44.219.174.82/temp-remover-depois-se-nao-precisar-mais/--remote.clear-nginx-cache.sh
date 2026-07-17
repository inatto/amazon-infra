#!/usr/bin/env bash
# DESATIVADO: substituído por deploy/07_IMPORTANTE_cache_clear.sh.
set -euo pipefail

REMOTE_USER="ubuntu"
REMOTE_HOST="44.219.174.82"
SSH_KEY="/home/daniel/amazon.ssh"

CACHE_DIR="/var/cache/nginx/astro"
SSH_OPTS="-i $SSH_KEY -o ServerAliveInterval=30 -o ServerAliveCountMax=120 -o TCPKeepAlive=yes"

echo "Limpando cache Nginx em $REMOTE_HOST..."
echo "Cache dir: $CACHE_DIR"
echo ""

ssh $SSH_OPTS "$REMOTE_USER@$REMOTE_HOST" "
  set -euo pipefail

  CACHE_DIR='$CACHE_DIR'

  echo '=== NGINX TEST ==='
  sudo nginx -t
  echo ''

  echo '=== CACHE ANTES ==='
  if [ -d \"\$CACHE_DIR\" ]; then
    echo 'Pasta:' \"\$CACHE_DIR\"
    echo -n 'Tamanho: '
    sudo du -sh \"\$CACHE_DIR\" | awk '{print \$1}'
    echo -n 'Arquivos: '
    sudo find \"\$CACHE_DIR\" -type f | wc -l
  else
    echo 'Pasta de cache ainda não existe:' \"\$CACHE_DIR\"
  fi
  echo ''

  echo '=== LIMPANDO CACHE ==='
  sudo mkdir -p \"\$CACHE_DIR\"
  sudo find \"\$CACHE_DIR\" -mindepth 1 -delete
  sudo chown -R www-data:www-data \"\$CACHE_DIR\"
  echo 'Cache limpo.'
  echo ''

  echo '=== RELOAD NGINX ==='
  sudo systemctl reload nginx
  echo ''

  echo '=== CACHE DEPOIS ==='
  echo -n 'Tamanho: '
  sudo du -sh \"\$CACHE_DIR\" | awk '{print \$1}'
  echo -n 'Arquivos: '
  sudo find \"\$CACHE_DIR\" -type f | wc -l
  echo ''

  echo '=== STATUS NGINX ==='
  systemctl is-active nginx
  systemctl --no-pager --lines=8 status nginx
  echo ''

  echo '=== CONFIG CACHE ATUAL ==='
  sudo nginx -T 2>/dev/null | grep -E 'proxy_cache_path|keys_zone=|max_size=|inactive=|proxy_cache_valid|X-Cache-Status' || true
"

echo ""
echo "Concluído."
