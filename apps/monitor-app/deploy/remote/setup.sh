#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/target.conf"
ROOT="$(cd -- "$DIR/../.." && pwd)"
SSH=(-i "$DEPLOY_SSH_KEY" -o BatchMode=yes)

echo "Sincronizando código com $DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST:$DEPLOY_REMOTE_DIR."
ssh "${SSH[@]}" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST" "mkdir -p '$DEPLOY_REMOTE_DIR'"
rsync -az --delete \
  --exclude '.env' \
  --exclude '.venv' \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --exclude '.astro' \
  --exclude '__pycache__' \
  -e "ssh -i $DEPLOY_SSH_KEY -o BatchMode=yes" \
  "$ROOT/" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST:$DEPLOY_REMOTE_DIR/"
echo "Código remoto sincronizado."

REPO_ROOT="$(cd -- "$ROOT/../.." && pwd)"
REMOTE_INFRA_DIR="/home/ubuntu/apps/infra/amazon-infra"
echo "Sincronizando pasta fonte de domínios da EC2."
ssh "${SSH[@]}" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST" "mkdir -p '$REMOTE_INFRA_DIR/ec2/$DEPLOY_REMOTE_HOST/domains'"
rsync -az --delete \
  -e "ssh -i $DEPLOY_SSH_KEY -o BatchMode=yes" \
  "$REPO_ROOT/ec2/$DEPLOY_REMOTE_HOST/domains/" \
  "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST:$REMOTE_INFRA_DIR/ec2/$DEPLOY_REMOTE_HOST/domains/"
echo "Pasta fonte de domínios sincronizada."

ssh "${SSH[@]}" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST" \
  "cd '$DEPLOY_REMOTE_DIR/deploy/remote' && ./setup-services.sh"
echo "Serviços systemd do monitor garantidos."

"$DIR/setup-admin-helper.sh"

"$DIR/setup-api.sh"
"$DIR/setup-web.sh"
