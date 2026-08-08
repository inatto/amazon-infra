#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/deploy
set -Eeuo pipefail

CONFIG_FILE="${1:-}"
[[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] || {
  echo "Uso: ./06-coletar-informacoes-do-servidor.sh ../domains/<dominio>.conf" >&2
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
    echo "Esperado, por exemplo: $INFRA_DIR/ec2/$REMOTE_HOST ou $INFRA_DIR/lightsail/$REMOTE_HOST" >&2
  else
    echo "ERRO: mais de uma pasta encontrada para REMOTE_HOST=$REMOTE_HOST:" >&2
    printf '  - %s\n' "${INSTANCE_DIRS[@]}" >&2
  fi
  exit 1
}

INSTANCE_DIR="${INSTANCE_DIRS[0]}"
DOMAINS_DIR="$INSTANCE_DIR/domains"
OUTPUT_FILE="$INSTANCE_DIR/server_backup/server-info.md"
TEMP_FILE="${OUTPUT_FILE}.tmp"

mapfile -t RELATED_CONFIGS < <(
  find "$DOMAINS_DIR" -maxdepth 1 -type f -name '*.conf' -print 2>/dev/null | sort | while IFS= read -r file; do
    bash -Eeuo pipefail -c '
      source "$1"
      [[ "${REMOTE_USER:-}" == "$2" && "${REMOTE_HOST:-}" == "$3" && "${SSH_KEY:-}" == "$4" ]] && printf "%s\n" "$1"
    ' _ "$file" "$REMOTE_USER" "$REMOTE_HOST" "$SSH_KEY"
  done
)
(( ${#RELATED_CONFIGS[@]} > 0 )) || RELATED_CONFIGS=("$CONFIG_FILE")

mapfile -t SYSTEMD_SERVICES < <(
  for file in "${RELATED_CONFIGS[@]}"; do
    bash -Eeuo pipefail -c '
      source "$1"
      declare -p SYSTEMD_SERVICES >/dev/null 2>&1 && printf "%s\n" "${SYSTEMD_SERVICES[@]}"
    ' _ "$file"
  done | sed '/^[[:space:]]*$/d' | sort -u
)

for service in "${SYSTEMD_SERVICES[@]}"; do
  [[ "$service" == *.service && "$service" != */* ]] || { echo "ERRO: nome de serviço inválido: $service" >&2; exit 1; }
done

mkdir -p "$(dirname -- "$OUTPUT_FILE")"
SERVICES_TEXT="$(printf '%s\n' "${SYSTEMD_SERVICES[@]}")"
printf 'Coletando informações de %s@%s...\n' "$REMOTE_USER" "$REMOTE_HOST"

if ! ssh -i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=15 \
  "$REMOTE_USER@$REMOTE_HOST" \
  "SERVICES_TEXT=$(printf '%q' "$SERVICES_TEXT") bash -s" >"$TEMP_FILE" <<'REMOTE'
set -Eeuo pipefail

code_block() {
  printf '```text\n'
  "$@" 2>&1 || true
  printf '```\n\n'
}

HOSTNAME_VALUE="$(hostname -f 2>/dev/null || hostname)"
OS_VALUE="$(. /etc/os-release 2>/dev/null && printf '%s' "${PRETTY_NAME:-desconhecido}" || printf 'desconhecido')"
printf '# Informações do servidor\n\n'
printf '> Gerado automaticamente. Os valores representam o momento da coleta.\n\n'
printf '| Item | Valor |\n|---|---|\n'
printf '| Coletado em | `%s` |\n' "$(date --iso-8601=seconds)"
printf '| Hostname | `%s` |\n' "$HOSTNAME_VALUE"
printf '| Sistema | `%s` |\n' "$OS_VALUE"
printf '| Kernel | `%s` |\n' "$(uname -r)"
printf '| Arquitetura | `%s` |\n' "$(uname -m)"
printf '| Uptime | `%s` |\n' "$(uptime -p 2>/dev/null || true)"
printf '| Inicializado em | `%s` |\n' "$(uptime -s 2>/dev/null || true)"
printf '| Carga 1/5/15 min | `%s` |\n' "$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || true)"
printf '| CPUs lógicas | `%s` |\n\n' "$(nproc 2>/dev/null || true)"

printf '## Memória e swap\n\n'; code_block free -h
printf '## Disco\n\n'; code_block df -hT -x tmpfs -x devtmpfs -x squashfs
printf '## Inodes\n\n'; code_block df -hi -x tmpfs -x devtmpfs -x squashfs
printf '## Processos\n\n'; code_block bash -c "printf 'Total: '; ps -e --no-headers | wc -l; uptime"
printf '## Rede\n\n### Endereços IP\n\n'; code_block hostname -I
printf '### Portas em escuta\n\n'
command -v ss >/dev/null 2>&1 && code_block ss -lntup || printf '_Comando `ss` não disponível._\n\n'

printf '## Nginx\n\n'
if command -v nginx >/dev/null 2>&1; then
  printf '### Validação\n\n'; code_block sudo nginx -t
  printf '### Estado\n\n'; code_block systemctl --no-pager --full status nginx
else
  printf '_Nginx não instalado._\n\n'
fi

printf '## Serviços das aplicações\n\n'
if [[ -z "${SERVICES_TEXT:-}" ]]; then
  printf '_Nenhum serviço declarado para este servidor._\n'
else
  while IFS= read -r service; do
    [[ -n "$service" ]] || continue
    printf '### `%s`\n\n' "$service"
    printf '| Propriedade | Valor |\n|---|---|\n'
    printf '| Ativo | `%s` |\n' "$(systemctl is-active "$service" 2>/dev/null || true)"
    printf '| Habilitado | `%s` |\n\n' "$(systemctl is-enabled "$service" 2>/dev/null || true)"
    code_block systemctl --no-pager --full status "$service"
  done <<< "$SERVICES_TEXT"
fi
REMOTE
then
  rm -f "$TEMP_FILE"
  echo "ERRO: não foi possível coletar as informações do servidor." >&2
  exit 1
fi

[[ -s "$TEMP_FILE" ]] || { rm -f "$TEMP_FILE"; echo "ERRO: o servidor não retornou informações." >&2; exit 1; }
mv -f "$TEMP_FILE" "$OUTPUT_FILE"
printf 'OK: informações gravadas em:\n%s\n' "$OUTPUT_FILE"
