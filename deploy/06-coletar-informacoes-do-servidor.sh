#!/usr/bin/env bash
# Execute a partir desta pasta deploy
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DOMAINS_DIR="$SERVER_DIR/domains"
OUTPUT_FILE="$SERVER_DIR/server/local-server-info.md"
TEMP_FILE="${OUTPUT_FILE}.tmp"

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

command -v ssh >/dev/null || {
  echo "ERRO: ssh não encontrado no WSL." >&2
  exit 1
}

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

for service in "${SYSTEMD_SERVICES[@]}"; do
  [[ "$service" == *.service && "$service" != */* ]] || {
    echo "ERRO: nome de serviço inválido em domains/*.conf: $service" >&2
    exit 1
  }
done

mkdir -p "$(dirname -- "$OUTPUT_FILE")"
SERVICES_TEXT="$(printf '%s\n' "${SYSTEMD_SERVICES[@]}")"

printf 'Coletando informações de %s@%s...\n' "$REMOTE_USER" "$REMOTE_HOST"

if ! ssh \
  -i "$SSH_KEY" \
  -o BatchMode=yes \
  -o ConnectTimeout=15 \
  "$REMOTE_USER@$REMOTE_HOST" \
  "SERVICES_TEXT=$(printf '%q' "$SERVICES_TEXT") bash -s" >"$TEMP_FILE" <<'REMOTE'
set -Eeuo pipefail

markdown_code() {
  local language="$1"
  shift
  printf '```%s\n' "$language"
  "$@" 2>&1 || true
  printf '```\n\n'
}

HOSTNAME_VALUE="$(hostname -f 2>/dev/null || hostname)"
OS_VALUE="$(. /etc/os-release 2>/dev/null && printf '%s' "${PRETTY_NAME:-desconhecido}" || printf 'desconhecido')"
KERNEL_VALUE="$(uname -r)"
ARCH_VALUE="$(uname -m)"
UPTIME_VALUE="$(uptime -p 2>/dev/null || true)"
BOOT_VALUE="$(uptime -s 2>/dev/null || true)"
LOAD_VALUE="$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || true)"
CPU_MODEL="$(lscpu 2>/dev/null | awk -F: '/Model name/{sub(/^[[:space:]]+/, "", $2); print $2; exit}')"
CPU_COUNT="$(nproc 2>/dev/null || true)"
COLLECTED_AT="$(date --iso-8601=seconds)"

printf '# Informações do servidor\n\n'
printf '> Arquivo gerado automaticamente pelo passo 06. Os valores representam o momento da coleta.\n\n'
printf '| Item | Valor |\n'
printf '|---|---|\n'
printf '| Coletado em | `%s` |\n' "$COLLECTED_AT"
printf '| Hostname | `%s` |\n' "$HOSTNAME_VALUE"
printf '| Sistema | `%s` |\n' "$OS_VALUE"
printf '| Kernel | `%s` |\n' "$KERNEL_VALUE"
printf '| Arquitetura | `%s` |\n' "$ARCH_VALUE"
printf '| Uptime | `%s` |\n' "${UPTIME_VALUE:-indisponível}"
printf '| Inicializado em | `%s` |\n' "${BOOT_VALUE:-indisponível}"
printf '| Carga (1, 5 e 15 min) | `%s` |\n' "${LOAD_VALUE:-indisponível}"
printf '| CPU | `%s` |\n' "${CPU_MODEL:-indisponível}"
printf '| CPUs lógicas | `%s` |\n\n' "${CPU_COUNT:-indisponível}"

printf '## Memória e swap\n\n'
markdown_code text free -h

printf '## Disco\n\n'
markdown_code text df -hT -x tmpfs -x devtmpfs -x squashfs

printf '## Inodes\n\n'
markdown_code text df -hi -x tmpfs -x devtmpfs -x squashfs

printf '## Processos e carga\n\n'
markdown_code text bash -c "printf 'Processos: '; ps -e --no-headers | wc -l; printf 'Load average: '; cat /proc/loadavg"

printf '## Rede\n\n'
printf '### Endereços IP\n\n'
markdown_code text hostname -I
printf '### Portas em escuta\n\n'
if command -v ss >/dev/null 2>&1; then
  markdown_code text ss -lntup
else
  printf '_Comando `ss` não disponível._\n\n'
fi

printf '## Nginx\n\n'
if command -v nginx >/dev/null 2>&1; then
  printf '### Validação da configuração\n\n'
  markdown_code text sudo nginx -t
  printf '### Estado do serviço\n\n'
  markdown_code text systemctl --no-pager --full status nginx
else
  printf '_Nginx não instalado._\n\n'
fi

printf '## Serviços das aplicações\n\n'
if [[ -z "${SERVICES_TEXT:-}" ]]; then
  printf '_Nenhum serviço declarado em `domains/*.conf`._\n'
else
  while IFS= read -r service; do
    [[ -n "$service" ]] || continue
    printf '### `%s`\n\n' "$service"
    printf '| Propriedade | Valor |\n'
    printf '|---|---|\n'
    printf '| Ativo | `%s` |\n' "$(systemctl is-active "$service" 2>/dev/null || true)"
    printf '| Habilitado | `%s` |\n\n' "$(systemctl is-enabled "$service" 2>/dev/null || true)"
    markdown_code text systemctl --no-pager --full status "$service"
  done <<< "$SERVICES_TEXT"
fi
REMOTE
then
  rm -f "$TEMP_FILE"
  echo "ERRO: não foi possível coletar as informações do servidor." >&2
  exit 1
fi

[[ -s "$TEMP_FILE" ]] || {
  rm -f "$TEMP_FILE"
  echo "ERRO: o servidor não retornou informações." >&2
  exit 1
}

mv -f "$TEMP_FILE" "$OUTPUT_FILE"
printf 'OK: informações gravadas em:\n%s\n' "$OUTPUT_FILE"
