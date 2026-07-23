#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/deploy
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
PORTS_FILE="$INFRA_DIR/core/portas-aplicacoes.md"

log() { printf '[dominio] %s\n' "$*"; }
die() { printf 'ERRO: %s\n' "$*" >&2; exit 1; }

trim() {
  local value="${1:-}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

prompt_required() {
  local label="$1" value
  while :; do
    read -r -p "$label: " value
    value="$(trim "$value")"
    [[ -n "$value" ]] && { printf '%s' "$value"; return; }
    echo 'Valor obrigatório.' >&2
  done
}

prompt_default() {
  local label="$1" default="$2" value
  read -r -p "$label [$default]: " value
  value="$(trim "$value")"
  printf '%s' "${value:-$default}"
}

choose_item() {
  local title="$1" default_index="$2"
  shift 2
  local -a items=("$@")
  local answer index

  (( ${#items[@]} > 0 )) || die "nenhuma opção encontrada para: $title"
  if (( ${#items[@]} == 1 )); then
    printf '%s' "${items[0]}"
    return
  fi

  echo "$title" >&2
  for index in "${!items[@]}"; do
    printf '  %d) %s%s\n' "$((index + 1))" "${items[$index]}" \
      "$([[ $index -eq $default_index ]] && printf ' [padrão]' || true)" >&2
  done

  while :; do
    read -r -p "Escolha [$((default_index + 1))]: " answer
    answer="${answer:-$((default_index + 1))}"
    if [[ "$answer" =~ ^[0-9]+$ ]] && (( answer >= 1 && answer <= ${#items[@]} )); then
      printf '%s' "${items[$((answer - 1))]}"
      return
    fi
    echo 'Opção inválida.' >&2
  done
}

usage() {
  cat <<'USAGE'
Uso:
  ./00-criar-configuracao-dominio.sh

O assistente pergunta somente dados que variam e deriva o restante de:
  - core/portas-aplicacoes.md
  - pastas ec2/* e lightsail/*
  - configurações existentes em domains/*.conf

Não possui domínio, aplicação, porta, IP, chave SSH ou serviço fixados.
USAGE
}

[[ "${1:-}" != '-h' && "${1:-}" != '--help' ]] || { usage; exit 0; }
[[ $# -eq 0 ]] || die 'este script é interativo e não aceita parâmetros; use --help.'
[[ -f "$PORTS_FILE" ]] || die "cadastro de portas não encontrado: $PORTS_FILE"

DOMAIN="$(prompt_required 'Domínio principal (ex.: previa.exemplo.org.br)')"
DOMAIN="${DOMAIN,,}"
[[ "$DOMAIN" =~ ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$ && "$DOMAIN" == *.* ]] || die "domínio inválido: $DOMAIN"

mapfile -t INSTANCE_DIRS < <(
  find "$INFRA_DIR/ec2" "$INFRA_DIR/lightsail" \
    -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort
)
(( ${#INSTANCE_DIRS[@]} > 0 )) || die 'nenhuma instância encontrada em ec2/ ou lightsail/.'

INSTANCE_OPTIONS=()
for path in "${INSTANCE_DIRS[@]}"; do
  INSTANCE_OPTIONS+=("${path#$INFRA_DIR/}")
done
INSTANCE_REL="$(choose_item 'Servidor de destino:' 0 "${INSTANCE_OPTIONS[@]}")"
INSTANCE_DIR="$INFRA_DIR/$INSTANCE_REL"
REMOTE_HOST="$(basename "$INSTANCE_DIR")"

mapfile -t PORT_ROWS < <(
  awk '
    /^[[:space:]]*-+[[:space:]]*$/ { next }
    NF >= 3 && $1 != "Aplicação" {
      # Apenas registros com porta web única, não faixas reservadas.
      if ($(NF-1) ~ /^[0-9]+$/) {
        api = ($NF ~ /^[0-9]+$/ && NF >= 4) ? $NF : "-"
        web = (api == "-") ? $NF : $(NF-1)
        type = $(NF-2)
        name = $1
        for (i = 2; i <= NF-3; i++) name = name " " $i
        print name "|" type "|" web "|" api
      }
    }
  ' "$PORTS_FILE"
)
(( ${#PORT_ROWS[@]} > 0 )) || die "nenhuma aplicação com porta individual encontrada em $PORTS_FILE"

APP_OPTIONS=()
for row in "${PORT_ROWS[@]}"; do
  IFS='|' read -r name type web api <<< "$row"
  if [[ "$api" == '-' ]]; then
    APP_OPTIONS+=("$name — $type — web $web")
  else
    APP_OPTIONS+=("$name — $type — web $web / api $api")
  fi
done
SELECTED_APP="$(choose_item 'Aplicação/portas:' 0 "${APP_OPTIONS[@]}")"
SELECTED_INDEX=-1
for i in "${!APP_OPTIONS[@]}"; do
  [[ "${APP_OPTIONS[$i]}" == "$SELECTED_APP" ]] && { SELECTED_INDEX=$i; break; }
done
(( SELECTED_INDEX >= 0 )) || die 'não foi possível identificar a aplicação selecionada.'
IFS='|' read -r PORT_APP_NAME APP_TYPE WEB_PORT API_PORT <<< "${PORT_ROWS[$SELECTED_INDEX]}"

# Sugestão neutra: remove qualificadores comuns de catálogo, mas sempre permite alteração.
APP_NAME_DEFAULT="$PORT_APP_NAME"
APP_NAME_DEFAULT="${APP_NAME_DEFAULT#site-}"
APP_NAME_DEFAULT="${APP_NAME_DEFAULT%-2026}"
APP_NAME="$(prompt_default 'Nome da aplicação/processo' "$APP_NAME_DEFAULT")"
[[ "$APP_NAME" =~ ^[A-Za-z0-9][A-Za-z0-9._/-]*$ ]] || die "nome de aplicação inválido: $APP_NAME"

DOMAINS=("$DOMAIN")
read -r -p 'Domínios adicionais separados por espaço (Enter para nenhum): ' EXTRA_DOMAINS_RAW
if [[ -n "$(trim "$EXTRA_DOMAINS_RAW")" ]]; then
  read -r -a EXTRA_DOMAINS <<< "$EXTRA_DOMAINS_RAW"
  for extra in "${EXTRA_DOMAINS[@]}"; do
    extra="${extra,,}"
    [[ "$extra" =~ ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$ && "$extra" == *.* ]] || die "domínio adicional inválido: $extra"
    DOMAINS+=("$extra")
  done
fi

mapfile -t SSH_KEYS < <(
  find "$INSTANCE_DIR/core" -maxdepth 1 -type f \
    \( -name '*.pem' -o -name '*.ssh' -o -name 'id_*' \) -print 2>/dev/null | sort
)
(( ${#SSH_KEYS[@]} > 0 )) || die "nenhuma chave SSH encontrada em $INSTANCE_DIR/core"
SSH_KEY="$(choose_item 'Chave SSH:' 0 "${SSH_KEYS[@]}")"

# Herda defaults operacionais de uma configuração existente da mesma instância.
REFERENCE_CONF="$(find "$INSTANCE_DIR/domains" -maxdepth 1 -type f -name '*.conf' -print 2>/dev/null | sort | head -n 1 || true)"
REMOTE_USER='ubuntu'
SSL_EMAIL=''
CLIENT_MAX_BODY_SIZE='20m'
WEB_PROXY_READ_TIMEOUT='60s'
API_PROXY_READ_TIMEOUT='120s'
API_PROXY_CONNECT_TIMEOUT='30s'
API_PROXY_SEND_TIMEOUT='120s'
if [[ -n "$REFERENCE_CONF" ]]; then
  # shellcheck disable=SC1090
  source "$REFERENCE_CONF"
  REMOTE_USER="${REMOTE_USER:-ubuntu}"
  SSL_EMAIL="${SSL_EMAIL:-}"
  CLIENT_MAX_BODY_SIZE="${CLIENT_MAX_BODY_SIZE:-20m}"
  WEB_PROXY_READ_TIMEOUT="${WEB_PROXY_READ_TIMEOUT:-60s}"
  API_PROXY_READ_TIMEOUT="${API_PROXY_READ_TIMEOUT:-120s}"
  API_PROXY_CONNECT_TIMEOUT="${API_PROXY_CONNECT_TIMEOUT:-30s}"
  API_PROXY_SEND_TIMEOUT="${API_PROXY_SEND_TIMEOUT:-120s}"
fi
[[ -n "$SSL_EMAIL" ]] || SSL_EMAIL="$(prompt_required 'E-mail para o certificado SSL')"

DOMAINS_DIR="$INSTANCE_DIR/domains"
CONFIG_FILE="$DOMAINS_DIR/$DOMAIN.conf"
mkdir -p "$DOMAINS_DIR"
[[ ! -e "$CONFIG_FILE" ]] || die "a configuração já existe e não será sobrescrita: $CONFIG_FILE"

SERVICE_BASE="${APP_NAME//\//-}"
WEB_SERVICE="${SERVICE_BASE}-web.service"
API_SERVICE="${SERVICE_BASE}-api.service"

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT
{
  printf '#!/usr/bin/env bash\n'
  printf '# cd %s\n\n' "$DOMAINS_DIR"
  printf 'REMOTE_USER=%q\n' "$REMOTE_USER"
  printf 'REMOTE_HOST=%q\n' "$REMOTE_HOST"
  printf 'SSH_KEY=%q\n\n' "$SSH_KEY"
  printf 'SITE_NAME=%q\n' "$DOMAIN"
  printf 'APP_NAME=%q\n\n' "$APP_NAME"
  printf 'DOMAINS=(\n'
  printf '  %q\n' "${DOMAINS[@]}"
  printf ')\n\n'
  printf 'WEB_UPSTREAM_HOST="127.0.0.1"\n'
  printf 'WEB_UPSTREAM_PORT=%q\n' "$WEB_PORT"
  if [[ "$API_PORT" != '-' ]]; then
    printf 'API_UPSTREAM_HOST="127.0.0.1"\n'
    printf 'API_UPSTREAM_PORT=%q\n' "$API_PORT"
  fi
  printf '\nSSL_EMAIL=%q\n' "$SSL_EMAIL"
  printf 'CLIENT_MAX_BODY_SIZE=%q\n' "$CLIENT_MAX_BODY_SIZE"
  printf 'WEB_PROXY_READ_TIMEOUT=%q\n' "$WEB_PROXY_READ_TIMEOUT"
  if [[ "$API_PORT" != '-' ]]; then
    printf 'API_PROXY_READ_TIMEOUT=%q\n' "$API_PROXY_READ_TIMEOUT"
    printf 'API_PROXY_CONNECT_TIMEOUT=%q\n' "$API_PROXY_CONNECT_TIMEOUT"
    printf 'API_PROXY_SEND_TIMEOUT=%q\n' "$API_PROXY_SEND_TIMEOUT"
  fi
  printf '\nSYSTEMD_SERVICES=(\n'
  if [[ "$API_PORT" != '-' ]]; then printf '  %q\n' "$API_SERVICE"; fi
  printf '  %q\n' "$WEB_SERVICE"
  printf ')\n'
} > "$TMP_FILE"

bash -n "$TMP_FILE"
install -m 0644 "$TMP_FILE" "$CONFIG_FILE"

RELATIVE_CONFIG="${CONFIG_FILE#$INFRA_DIR/}"
printf '\nConfiguração criada com sucesso.\n'
printf 'Arquivo: %s\n' "$CONFIG_FILE"
printf 'Aplicação: %s\n' "$PORT_APP_NAME"
printf 'Web: %s\n' "$WEB_PORT"
[[ "$API_PORT" == '-' ]] || printf 'API: %s\n' "$API_PORT"
printf '\nPróximo passo:\n  cd %q\n  ./01-testar-dns.sh %q\n' "$SCRIPT_DIR" "../$RELATIVE_CONFIG"
