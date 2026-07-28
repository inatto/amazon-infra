#!/usr/bin/env bash
# cd /home/daniel/Code/infra/amazon-infra/deploy
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

if [[ -t 1 ]]; then
  BOLD='\033[1m'
  BLUE='\033[1;34m'
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  RED='\033[1;31m'
  DIM='\033[2m'
  RESET='\033[0m'
else
  BOLD=''; BLUE=''; CYAN=''; GREEN=''; YELLOW=''; RED=''; DIM=''; RESET=''
fi

info() { printf '%b%s%b\n' "$CYAN" "$*" "$RESET"; }
ok() { printf '%bOK:%b %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%bATENÇÃO:%b %s\n' "$YELLOW" "$RESET" "$*"; }
die() { printf '%bERRO:%b %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }

CURRENT_STEP='preparação'
on_error() {
  local status=$?
  printf '\n%bFALHA NO PASSO:%b %s\n' "$RED" "$RESET" "$CURRENT_STEP" >&2
  printf '%bFluxo interrompido.%b Nenhum passo seguinte foi executado.\n' "$RED" "$RESET" >&2
  exit "$status"
}
trap on_error ERR

usage() {
  cat <<'USAGE'
Uso:
  ./configurar-dominio-passo-a-passo.sh
  ./configurar-dominio-passo-a-passo.sh ../ec2/<servidor>/domains/<dominio>.conf

Sem parâmetro:
  executa o passo 00, identifica a nova configuração criada e conduz os passos 01 a 06.

Com parâmetro:
  usa uma configuração já existente e conduz os passos 01 a 06.

Antes de cada passo seguinte, pede confirmação. Em qualquer erro, para imediatamente.
USAGE
}

confirm_next() {
  local number="$1" title="$2" answer
  printf '\n%bPróximo passo %s:%b %s\n' "$BOLD" "$number" "$RESET" "$title"
  while :; do
    read -r -p "Pressione Enter para executar ou digite Q para encerrar: " answer
    case "${answer,,}" in
      '') return 0 ;;
      q|sair) return 1 ;;
      *) warn 'Opção inválida. Use Enter para continuar ou Q para encerrar.' ;;
    esac
  done
}

run_step() {
  local number="$1" title="$2" script="$3"
  shift 3
  CURRENT_STEP="$number - $title"
  printf '\n%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n' "$BLUE" "$RESET"
  printf '%bPASSO %s — %s%b\n' "$BLUE" "$number" "$title" "$RESET"
  printf '%bComando:%b %s' "$DIM" "$RESET" "$script"
  printf ' %q' "$@"
  printf '\n%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n\n' "$BLUE" "$RESET"
  "$script" "$@"
  ok "passo $number concluído: $title"
}

resolve_config_path() {
  local input="$1"
  if [[ -f "$input" ]]; then
    realpath "$input"
    return
  fi
  if [[ -f "$SCRIPT_DIR/$input" ]]; then
    realpath "$SCRIPT_DIR/$input"
    return
  fi
  die "configuração não encontrada: $input"
}

[[ "${1:-}" != '-h' && "${1:-}" != '--help' ]] || { usage; exit 0; }
[[ $# -le 1 ]] || die 'informe no máximo um arquivo .conf.'

printf '%bCONFIGURAÇÃO DE DOMÍNIO — FLUXO GUIADO%b\n' "$BOLD" "$RESET"
printf 'O fluxo executa claramente os passos 00 a 06, confirma antes do próximo e para no primeiro erro.\n'

CONFIG_FILE=''
if [[ $# -eq 1 ]]; then
  CONFIG_FILE="$(resolve_config_path "$1")"
  info "Configuração existente: $CONFIG_FILE"
else
  mapfile -t BEFORE_CONFIGS < <(
    find "$INFRA_DIR/ec2" "$INFRA_DIR/lightsail" -path '*/domains/*.conf' -type f -print 2>/dev/null | sort
  )

  if ! confirm_next '00' 'Criar configuração do domínio'; then
    warn 'Fluxo encerrado antes do passo 00.'
    exit 0
  fi
  run_step '00' 'Criar configuração do domínio' "$SCRIPT_DIR/00-criar-configuracao-dominio.sh"

  mapfile -t AFTER_CONFIGS < <(
    find "$INFRA_DIR/ec2" "$INFRA_DIR/lightsail" -path '*/domains/*.conf' -type f -print 2>/dev/null | sort
  )
  mapfile -t NEW_CONFIGS < <(
    comm -13 <(printf '%s\n' "${BEFORE_CONFIGS[@]}" | sed '/^$/d' | sort) \
             <(printf '%s\n' "${AFTER_CONFIGS[@]}" | sed '/^$/d' | sort)
  )

  (( ${#NEW_CONFIGS[@]} == 1 )) || {
    if (( ${#NEW_CONFIGS[@]} == 0 )); then
      die 'o passo 00 terminou, mas nenhuma nova configuração .conf foi identificada.'
    fi
    printf '%s\n' "${NEW_CONFIGS[@]}" >&2
    die 'mais de uma configuração nova foi identificada; execute novamente informando explicitamente o arquivo .conf.'
  }
  CONFIG_FILE="${NEW_CONFIGS[0]}"
  ok "configuração identificada: $CONFIG_FILE"
fi

STEPS=(
  '01|Testar DNS|01-testar-dns.sh'
  '02|Configurar Nginx|02-configurar-nginx.sh'
  '03|Instalar certificado SSL|03-instalar-ssl.sh'
  '04|Instalar serviços systemd|04-instalar-servicos.sh'
  '05|Copiar configurações do servidor|05-copiar-configuracoes-do-servidor.sh'
  '06|Coletar informações do servidor|06-coletar-informacoes-do-servidor.sh'
)

for row in "${STEPS[@]}"; do
  IFS='|' read -r number title filename <<< "$row"
  if ! confirm_next "$number" "$title"; then
    warn "Fluxo encerrado pelo usuário antes do passo $number."
    printf 'Para continuar depois, execute:\n  %q %q\n' "$0" "$CONFIG_FILE"
    exit 0
  fi
  run_step "$number" "$title" "$SCRIPT_DIR/$filename" "$CONFIG_FILE"
done

printf '\n%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n' "$GREEN" "$RESET"
printf '%bFLUXO CONCLUÍDO COM SUCESSO%b\n' "$GREEN" "$RESET"
printf 'Configuração usada: %s\n' "$CONFIG_FILE"
printf '%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n' "$GREEN" "$RESET"
