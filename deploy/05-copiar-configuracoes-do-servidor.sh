#!/usr/bin/env bash
# Execute a partir desta pasta deploy
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DOMAINS_DIR="$SERVER_DIR/domains"
LOCAL_SERVER_DIR="$SERVER_DIR/server"

mapfile -t CONFIG_FILES < <(find "$DOMAINS_DIR" -maxdepth 1 -type f -name '*.conf' -print 2>/dev/null | sort)
(( ${#CONFIG_FILES[@]} > 0 )) || {
  echo "ERRO: nenhum arquivo encontrado em $DOMAINS_DIR/*.conf" >&2
  exit 1
}

read_connection() {
  bash -Eeuo pipefail -c '
    source "$1"
    : "${REMOTE_USER:?Defina REMOTE_USER}"
    : "${REMOTE_HOST:?Defina REMOTE_HOST}"
    : "${SSH_KEY:?Defina SSH_KEY}"
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

[[ -f "$SSH_KEY" ]] || {
  echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2
  exit 1
}

command -v rsync >/dev/null || {
  echo "ERRO: rsync não encontrado no WSL." >&2
  exit 1
}

SSH_COMMAND="ssh -i $SSH_KEY -o BatchMode=yes -o ConnectTimeout=15"

mapfile -t SYSTEMD_SERVICES < <(
  for config_file in "${CONFIG_FILES[@]}"; do
    bash -Eeuo pipefail -c '
      source "$1"
      if declare -p SYSTEMD_SERVICES >/dev/null 2>&1; then
        printf "%s\n" "${SYSTEMD_SERVICES[@]}"
      fi
    ' _ "$config_file"
  done | sed '/^[[:space:]]*$/d' | sort -u
)

if (( ${#SYSTEMD_SERVICES[@]} == 0 )); then
  echo "ERRO: nenhum serviço foi declarado em domains/*.conf (SYSTEMD_SERVICES)." >&2
  exit 1
fi

printf '\nCopiando configurações gerais do servidor %s...\n\n' "$REMOTE_HOST"
printf 'Serviços encontrados nos arquivos de domínio:\n'
printf '  - %s\n' "${SYSTEMD_SERVICES[@]}"
printf '\n'

mkdir -p \
  "$LOCAL_SERVER_DIR/etc/nginx" \
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

printf '\n2/3 Copiando somente os serviços declarados em domains/*.conf...\n'
rm -rf "$LOCAL_SERVER_DIR/etc/systemd/system"
mkdir -p "$LOCAL_SERVER_DIR/etc/systemd/system"

for service in "${SYSTEMD_SERVICES[@]}"; do
  [[ "$service" == *.service && "$service" != */* ]] || {
    echo "ERRO: nome de serviço inválido em domains/*.conf: $service" >&2
    exit 1
  }

  rsync -avz \
    --no-owner \
    --no-group \
    -e "$SSH_COMMAND" \
    --rsync-path="sudo rsync" \
    "$REMOTE_USER@$REMOTE_HOST:/etc/systemd/system/$service" \
    "$LOCAL_SERVER_DIR/etc/systemd/system/"
done

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
  '- Somente serviços declarados em domains/*.conf' \
  '- Configurações de renovação do Certbot (*.conf)' \
  '- Certificados e chaves privadas não foram copiados'
