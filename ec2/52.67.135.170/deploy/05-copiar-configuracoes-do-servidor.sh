#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/deploy
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
REMOTE_USER="ubuntu"
REMOTE_HOST="52.67.135.170"
SSH_KEY="$SERVER_DIR/core/inatto01-sp.pem"
LOCAL_SERVER_DIR="$SERVER_DIR/server"

[[ -f "$SSH_KEY" ]] || {
  echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2
  exit 1
}

command -v rsync >/dev/null || {
  echo "ERRO: rsync não encontrado no WSL." >&2
  exit 1
}

SSH_COMMAND="ssh -i $SSH_KEY -o BatchMode=yes -o ConnectTimeout=15"

printf '\nCopiando configurações gerais do servidor %s...\n\n' "$REMOTE_HOST"

mkdir -p \
  "$LOCAL_SERVER_DIR/etc/nginx" \
  "$LOCAL_SERVER_DIR/etc/systemd/system" \
  "$LOCAL_SERVER_DIR/etc/letsencrypt/renewal"

printf '1/3 Copiando /etc/nginx completo...\n'
rsync -avz \
  --delete \
  --no-owner \
  --no-group \
  -e "$SSH_COMMAND" \
  --rsync-path="sudo rsync" \
  "$REMOTE_USER@$REMOTE_HOST:/etc/nginx/" \
  "$LOCAL_SERVER_DIR/etc/nginx/"

printf '\n2/3 Copiando serviços systemd (*.service)...\n'
rsync -avz \
  --delete \
  --no-owner \
  --no-group \
  --include='*/' \
  --include='*.service' \
  --exclude='*' \
  -e "$SSH_COMMAND" \
  --rsync-path="sudo rsync" \
  "$REMOTE_USER@$REMOTE_HOST:/etc/systemd/system/" \
  "$LOCAL_SERVER_DIR/etc/systemd/system/"

printf '\n3/3 Copiando configurações públicas de renovação do Certbot (*.conf)...\n'
rsync -avz \
  --delete \
  --no-owner \
  --no-group \
  --include='*.conf' \
  --exclude='*' \
  -e "$SSH_COMMAND" \
  --rsync-path="sudo rsync" \
  "$REMOTE_USER@$REMOTE_HOST:/etc/letsencrypt/renewal/" \
  "$LOCAL_SERVER_DIR/etc/letsencrypt/renewal/"

printf '\nOK: configurações copiadas para:\n%s\n' "$LOCAL_SERVER_DIR"
printf '%s\n' \
  '- Nginx completo' \
  '- Serviços systemd (*.service)' \
  '- Configurações de renovação do Certbot (*.conf)' \
  '- Certificados e chaves privadas não foram copiados'
