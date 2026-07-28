#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/deploy/00-criar-configuracao-dominio.sh"
CONFIG="$ROOT/ec2/52.67.135.170/domains/content.anpprev.org.conf"

[[ -f "$CONFIG" ]]
BEFORE="$(sha256sum "$CONFIG")"
OUTPUT="$(printf 'content.anpprev.org\n1\nn\n' | "$SCRIPT" 2>&1)"
AFTER="$(sha256sum "$CONFIG")"

[[ "$BEFORE" == "$AFTER" ]]
[[ "$OUTPUT" == *'Deseja sobrescrever? [s/N]:'* ]]
[[ "$OUTPUT" == *'Configuração mantida sem alterações.'* ]]

echo 'OK: configuração existente exige confirmação e N preserva o arquivo sem alterações.'
