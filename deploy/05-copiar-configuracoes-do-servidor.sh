#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./05-copiar-configuracoes-do-servidor.sh ../domains/<dominio>.conf" >&2
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=/dev/null
source "$CONFIG_FILE"
: "${REMOTE_USER:?Defina REMOTE_USER em $CONFIG_FILE}"
: "${REMOTE_HOST:?Defina REMOTE_HOST em $CONFIG_FILE}"
: "${SSH_KEY:?Defina SSH_KEY em $CONFIG_FILE}"

[[ -f "$SSH_KEY" ]] || { echo "ERRO: chave SSH não encontrada: $SSH_KEY" >&2; exit 1; }
command -v rsync >/dev/null || { echo "ERRO: rsync não encontrado no WSL." >&2; exit 1; }

mapfile -t INSTANCE_DIRS < <(
  find "$INFRA_DIR" -mindepth 2 -maxdepth 2 -type d -name "$REMOTE_HOST" -print | sort
)
(( ${#INSTANCE_DIRS[@]} == 1 )) || {
  if (( ${#INSTANCE_DIRS[@]} == 0 )); then
    echo "ERRO: pasta da instância não encontrada para REMOTE_HOST=$REMOTE_HOST." >&2
    echo "Esperado, por exemplo: $INFRA_DIR/ec2/$REMOTE_HOST ou $INFRA_DIR/lightsail/$REMOTE_HOST" >&2
  else
    echo "ERRO: mais de uma pasta encontrada para REMOTE_HOST=$REMOTE_HOST:" >&2
    printf '  - %s\n' "${INSTANCE_DIRS[@]}" >&2
  fi
  exit 1
}

INSTANCE_DIR="${INSTANCE_DIRS[0]}"
DOMAINS_DIR="$INSTANCE_DIR/domains"
LOCAL_SERVER_DIR="$INSTANCE_DIR/server_backup"
SSH_COMMAND="ssh -i $SSH_KEY -o BatchMode=yes -o ConnectTimeout=15"

mapfile -t RELATED_CONFIGS < <(
  find "$DOMAINS_DIR" -maxdepth 1 -type f -name '*.conf' -print 2>/dev/null | sort
)
(( ${#RELATED_CONFIGS[@]} > 0 )) || {
  echo "ERRO: nenhum arquivo .conf encontrado em $DOMAINS_DIR" >&2
  exit 1
}

mapfile -t SYSTEMD_SERVICES < <(
  for file in "${RELATED_CONFIGS[@]}"; do
    bash -Eeuo pipefail -c '
      source "$1"
      declare -p SYSTEMD_SERVICES >/dev/null 2>&1 && printf "%s\n" "${SYSTEMD_SERVICES[@]}"
    ' _ "$file"
  done | sed '/^[[:space:]]*$/d' | sort -u
)


for service in "${SYSTEMD_SERVICES[@]}"; do
  [[ "$service" == *.service && "$service" != */* ]] || {
    echo "ERRO: nome de serviço inválido: $service" >&2
    exit 1
  }
done

printf '\nServidor: %s@%s\nDestino local: %s\n\n' "$REMOTE_USER" "$REMOTE_HOST" "$LOCAL_SERVER_DIR"
mkdir -p "$LOCAL_SERVER_DIR/etc/nginx" "$LOCAL_SERVER_DIR/etc/systemd/system" "$LOCAL_SERVER_DIR/etc/letsencrypt/renewal"

printf '1/3 Copiando /etc/nginx completo...\n'
rsync -avz --delete --no-owner --no-group \
  -e "$SSH_COMMAND" --rsync-path="sudo rsync" \
  "$REMOTE_USER@$REMOTE_HOST:/etc/nginx/" \
  "$LOCAL_SERVER_DIR/etc/nginx/"

printf '\n2/3 Copiando serviços declarados pelos domínios deste servidor...\n'
rm -rf "$LOCAL_SERVER_DIR/etc/systemd/system"
mkdir -p "$LOCAL_SERVER_DIR/etc/systemd/system"
for service in "${SYSTEMD_SERVICES[@]}"; do
  rsync -avz --no-owner --no-group \
    -e "$SSH_COMMAND" --rsync-path="sudo rsync" \
    "$REMOTE_USER@$REMOTE_HOST:/etc/systemd/system/$service" \
    "$LOCAL_SERVER_DIR/etc/systemd/system/"
done

printf '\n3/3 Copiando /etc/letsencrypt/renewal completo...\n'
mkdir -p "$LOCAL_SERVER_DIR/etc/letsencrypt/renewal"
rsync -avz --delete --no-owner --no-group \
  -e "$SSH_COMMAND" --rsync-path="sudo rsync" \
  "$REMOTE_USER@$REMOTE_HOST:/etc/letsencrypt/renewal/" \
  "$LOCAL_SERVER_DIR/etc/letsencrypt/renewal/"

printf '\nOK: configurações copiadas para:\n%s\n' "$LOCAL_SERVER_DIR"
