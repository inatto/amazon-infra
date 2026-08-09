#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./07-coletar-logs-do-servidor.sh ../domains/<dominio>.conf" >&2
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
command -v ssh >/dev/null || { echo "ERRO: ssh não encontrado no WSL." >&2; exit 1; }

mapfile -t INSTANCE_DIRS < <(
  find "$INFRA_DIR" -mindepth 2 -maxdepth 2 -type d -name "$REMOTE_HOST" -print | sort
)
(( ${#INSTANCE_DIRS[@]} == 1 )) || {
  if (( ${#INSTANCE_DIRS[@]} == 0 )); then
    echo "ERRO: pasta da instância não encontrada para REMOTE_HOST=$REMOTE_HOST." >&2
  else
    echo "ERRO: mais de uma pasta encontrada para REMOTE_HOST=$REMOTE_HOST:" >&2
    printf '  - %s\n' "${INSTANCE_DIRS[@]}" >&2
  fi
  exit 1
}

INSTANCE_DIR="${INSTANCE_DIRS[0]}"
OUTPUT_FILE="$INSTANCE_DIR/server_backup/server.log"
TEMP_FILE="${OUTPUT_FILE}.tmp"

mkdir -p "$(dirname -- "$OUTPUT_FILE")"
printf 'Coletando logs de %s@%s...\n' "$REMOTE_USER" "$REMOTE_HOST"

if ! ssh -i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=15 \
  "$REMOTE_USER@$REMOTE_HOST" \
  "bash -s" >"$TEMP_FILE" <<'REMOTE'
set -Eeuo pipefail

section() {
  printf '\n================================================================================\n'
  printf '%s\n' "$1"
  printf '================================================================================\n'
}

run() {
  "$@" 2>&1 || true
}

sanitize() {
  sed -E \
    -e 's/(Authorization:?[[:space:]]*(Bearer|Basic))[[:space:]]+[^[:space:]]+/\1 [REDACTED]/Ig' \
    -e 's/((password|passwd|pwd|secret|token|api[_-]?key|client[_-]?secret)["'"'"']?[[:space:]]*[:=][[:space:]]*)[^,;[:space:]"'"'"']+/\1[REDACTED]/Ig' \
    -e 's#(https?://)[^/@[:space:]]+:[^/@[:space:]]+@#\1[REDACTED]@#g'
}

{
  printf 'SERVER DIAGNOSTIC LOG\n'
  printf 'Collected: %s\n' "$(date --iso-8601=seconds)"
  printf 'Hostname: %s\n' "$(hostname -f 2>/dev/null || hostname)"
  printf 'Window: last 24 hours; maximum 200 journal lines per unit\n'

  section 'FAILED SYSTEMD UNITS'
  run systemctl --failed --no-pager --full

  section 'NGINX SERVICE STATUS'
  run systemctl status nginx --no-pager --full

  section 'NGINX CONFIGURATION TEST'
  run sudo nginx -t

  section 'NGINX JOURNAL — LAST 24 HOURS'
  run journalctl -u nginx.service --since '24 hours ago' -n 200 --no-pager -o short-iso

  section 'NGINX ERROR LOG — LAST 300 LINES'
  if [[ -r /var/log/nginx/error.log ]]; then
    run tail -n 300 /var/log/nginx/error.log
  else
    run sudo tail -n 300 /var/log/nginx/error.log
  fi

  section 'SYSTEM ERRORS — LAST 24 HOURS'
  run journalctl --since '24 hours ago' -p err..alert -n 300 --no-pager -o short-iso

  section 'RECENT KERNEL WARNINGS AND ERRORS'
  run journalctl -k --since '24 hours ago' -p warning..alert -n 200 --no-pager -o short-iso

  section 'LISTENING TCP/UDP PORTS'
  if command -v ss >/dev/null 2>&1; then
    run sudo ss -lntup
  else
    printf 'Command ss is unavailable.\n'
  fi

  section 'TOP PROCESSES BY MEMORY'
  run ps -eo pid,ppid,user,%mem,%cpu,etime,comm,args --sort=-%mem
} | sanitize
REMOTE
then
  rm -f "$TEMP_FILE"
  echo "ERRO: não foi possível coletar os logs do servidor." >&2
  exit 1
fi

[[ -s "$TEMP_FILE" ]] || {
  rm -f "$TEMP_FILE"
  echo "ERRO: o servidor não retornou logs." >&2
  exit 1
}

mv -f "$TEMP_FILE" "$OUTPUT_FILE"
printf 'OK: logs gravados em:\n%s\n' "$OUTPUT_FILE"
