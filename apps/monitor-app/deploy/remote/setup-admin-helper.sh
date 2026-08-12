#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HELPER_SOURCE="$DIR/amazon-infra-nginx"
HELPER_TARGET="/usr/local/sbin/amazon-infra-nginx"
SUDOERS_TARGET="/etc/sudoers.d/monitor-app"
LEGACY_SUDOERS="/etc/sudoers.d/amazon-infra-monitor"
REMOTE_USER="$(id -un)"

sudo install -m 0755 "$HELPER_SOURCE" "$HELPER_TARGET"
sudo rm -f "$LEGACY_SUDOERS"
printf '%s ALL=(root) NOPASSWD: /usr/local/sbin/amazon-infra-nginx *\n' "$REMOTE_USER" | sudo tee "$SUDOERS_TARGET" >/dev/null
sudo chmod 0440 "$SUDOERS_TARGET"
sudo visudo -cf "$SUDOERS_TARGET" >/dev/null
echo "Helper administrativo Nginx instalado."
