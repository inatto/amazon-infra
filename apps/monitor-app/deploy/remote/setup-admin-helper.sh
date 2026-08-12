#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HELPER_SOURCE="$DIR/amazon-infra-nginx"
HELPER_TARGET="/usr/local/sbin/amazon-infra-nginx"
SUDOERS_TARGET="/etc/sudoers.d/amazon-infra-monitor"

sudo install -m 0755 "$HELPER_SOURCE" "$HELPER_TARGET"
printf '%s\n' 'ubuntu ALL=(root) NOPASSWD: /usr/local/sbin/amazon-infra-nginx *' | sudo tee "$SUDOERS_TARGET" >/dev/null
sudo chmod 0440 "$SUDOERS_TARGET"
sudo visudo -cf "$SUDOERS_TARGET" >/dev/null
echo "Helper administrativo Nginx instalado."
