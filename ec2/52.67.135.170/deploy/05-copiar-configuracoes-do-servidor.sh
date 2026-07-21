#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/deploy
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVER_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DOMAINS_DIR="$SERVER_ROOT/domains"
LOCAL_SERVER_DIR="$SERVER_ROOT/server"

mapfile -t CONFIG_FILES < <(find "$DOMAINS_DIR" -maxdepth 1 -type f -name '*.conf' -print | sort)
(( ${#CONFIG_FILES[@]} > 0 )) || {
  echo "ERRO: nenhum arquivo encontrado em $DOMAINS_DIR/*.conf" >&2
  exit 1
}

read_connection() {
  bash -Eeuo pipefail -c '
    source "$1"
    printf "%s\n%s\n%s\n" "$REMOTE_USER" "$REMOTE_HOST" "$SSH_KEY"
  ' _ "$1"
}

mapfile -t CONNECTION < <(read_connection "${CONFIG_FILES[0]}")
REMOTE_USER="${CONNECTION[0]}"
REMOTE_HOST="${CONNECTION[1]}"
SSH_KEY="${CONNECTION[2]}"

for config_file in "${CONFIG_FILES[@]:1}"; do
  mapfile -t CURRENT < <(read_connection "$config_file")
  [[ "${CURRENT[0]}" == "$REMOTE_USER" && "${CURRENT[1]}" == "$REMOTE_HOST" && "${CURRENT[2]}" == "$SSH_KEY" ]] || {
    echo "ERRO: conexão divergente em $config_file" >&2
    exit 1
  }
done

[[ -f "$SSH_KEY" ]] || { echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2; exit 1; }
command -v rsync >/dev/null || { echo "ERRO: rsync não encontrado no WSL." >&2; exit 1; }

mapfile -t SYSTEMD_SERVICES < <(
  for config_file in "${CONFIG_FILES[@]}"; do
    bash -Eeuo pipefail -c '
      source "$1"
      declare -p SYSTEMD_SERVICES >/dev/null 2>&1 || exit 0
      printf "%s\n" "${SYSTEMD_SERVICES[@]}"
    ' _ "$config_file"
  done | sed '/^[[:space:]]*$/d' | sort -u
)

mapfile -t CERT_NAMES < <(
  for config_file in "${CONFIG_FILES[@]}"; do
    bash -Eeuo pipefail -c '
      source "$1"
      declare -p DOMAINS >/dev/null 2>&1 && (( ${#DOMAINS[@]} > 0 )) || exit 0
      printf "%s\n" "${DOMAINS[0]}"
    ' _ "$config_file"
  done | sed '/^[[:space:]]*$/d' | sort -u
)

SSH_COMMAND="ssh -i $SSH_KEY -o BatchMode=yes -o ConnectTimeout=15"

printf '\nCopiando configurações do servidor %s...\n\n' "$REMOTE_HOST"

printf '1/3 Nginx completo...\n'
mkdir -p "$LOCAL_SERVER_DIR/etc/nginx"
rsync -avz --delete --no-owner --no-group \
  -e "$SSH_COMMAND" \
  --rsync-path="sudo rsync" \
  "$REMOTE_USER@$REMOTE_HOST:/etc/nginx/" \
  "$LOCAL_SERVER_DIR/etc/nginx/"

printf '\n2/3 Serviços declarados em domains/*.conf...\n'
rm -rf "$LOCAL_SERVER_DIR/etc/systemd/system"
mkdir -p "$LOCAL_SERVER_DIR/etc/systemd/system"
for service in "${SYSTEMD_SERVICES[@]}"; do
  [[ "$service" =~ ^[A-Za-z0-9_.@-]+\.service$ ]] || {
    echo "ERRO: serviço inválido em domains/*.conf: $service" >&2
    exit 1
  }
  rsync -avz --no-owner --no-group \
    -e "$SSH_COMMAND" \
    --rsync-path="sudo rsync" \
    "$REMOTE_USER@$REMOTE_HOST:/etc/systemd/system/$service" \
    "$LOCAL_SERVER_DIR/etc/systemd/system/"
done

printf '\n3/3 Renovações SSL dos domínios cadastrados...\n'
rm -rf "$LOCAL_SERVER_DIR/etc/letsencrypt/renewal"
mkdir -p "$LOCAL_SERVER_DIR/etc/letsencrypt/renewal"
for cert_name in "${CERT_NAMES[@]}"; do
  rsync -avz --no-owner --no-group \
    -e "$SSH_COMMAND" \
    --rsync-path="sudo rsync" \
    "$REMOTE_USER@$REMOTE_HOST:/etc/letsencrypt/renewal/$cert_name.conf" \
    "$LOCAL_SERVER_DIR/etc/letsencrypt/renewal/"
done

printf '\nOK: configurações copiadas para %s\n' "$LOCAL_SERVER_DIR"
