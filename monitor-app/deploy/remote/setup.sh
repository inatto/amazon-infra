#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/target.conf"
ROOT="$(cd -- "$DIR/../.." && pwd)"
SSH=(-i "$DEPLOY_SSH_KEY" -o BatchMode=yes)
ssh "${SSH[@]}" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST" "mkdir -p '$DEPLOY_REMOTE_DIR'"
rsync -az --delete --exclude '.env' --exclude '.venv' --exclude 'node_modules' --exclude 'dist' --exclude '.astro' -e "ssh -i $DEPLOY_SSH_KEY -o BatchMode=yes" "$ROOT/" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST:$DEPLOY_REMOTE_DIR/"
ssh -t "${SSH[@]}" "$DEPLOY_REMOTE_USER@$DEPLOY_REMOTE_HOST" "cd '$DEPLOY_REMOTE_DIR/deploy/remote' && ./setup-api.sh && ./setup-web.sh"
