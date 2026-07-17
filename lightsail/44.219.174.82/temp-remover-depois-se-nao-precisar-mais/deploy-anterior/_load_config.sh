#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
# Carregador robusto: funciona executando ./script.sh e tambem se colar no terminal dentro da pasta deploy.
SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd -- "$(dirname -- "$SCRIPT_SOURCE")" 2>/dev/null && pwd || pwd)"

if [[ -f "$SCRIPT_DIR/00_IMPORTANTE_config.sh" ]]; then
  source "$SCRIPT_DIR/00_IMPORTANTE_config.sh"
elif [[ -f "./00_IMPORTANTE_config.sh" ]]; then
  source "./00_IMPORTANTE_config.sh"
elif [[ -f "./deploy/00_IMPORTANTE_config.sh" ]]; then
  source "./deploy/00_IMPORTANTE_config.sh"
else
  echo "ERRO: nao achei 00_IMPORTANTE_config.sh"
  echo "Execute de dentro da pasta deploy, exemplo:"
  echo "  cd deploy"
  echo "  ./01_IMPORTANTE_status.sh"
  exit 1
fi
