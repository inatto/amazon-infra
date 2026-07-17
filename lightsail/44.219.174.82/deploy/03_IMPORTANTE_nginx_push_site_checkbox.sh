#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)/_load_config.sh"

LOCAL_SITES_DIR="$LOCAL_SERVER_ABS/etc/nginx/sites-available"

print_line() {
  printf '%*s\n' "${COLUMNS:-100}" '' | tr ' ' '-'
}

print_box_header() {
  local title="$1"
  local width="${COLUMNS:-100}"
  printf '\n'
  printf '╔'
  printf '%*s' "$((width-2))" '' | tr ' ' '═'
  printf '╗\n'
  printf '║ %-*s ║\n' "$((width-4))" "$title"
  printf '╚'
  printf '%*s' "$((width-2))" '' | tr ' ' '═'
  printf '╝\n'
}

die() {
  echo "ERRO: $*" >&2
  exit 1
}

list_local_sites() {
  find "$LOCAL_SITES_DIR" -maxdepth 1 -type f -printf '%f\n' | sort
}

select_sites_interactive() {
  mapfile -t OPTIONS < <(list_local_sites)

  if [[ "${#OPTIONS[@]}" -eq 0 ]]; then
    die "nenhum arquivo encontrado em $LOCAL_SITES_DIR"
  fi

  SELECTED=()
  for _ in "${OPTIONS[@]}"; do SELECTED+=(0); done

  while true; do
    clear || true
    echo "Escolha um ou mais arquivos Nginx para enviar"
    echo ""
    echo "Comandos:"
    echo "  numero  = marca/desmarca"
    echo "  a       = marca todos"
    echo "  l       = limpa selecao"
    echo "  c       = confirma"
    echo "  q       = sai"
    echo ""
    echo "Exemplos:"
    echo "  1"
    echo "  1 3 4"
    echo "  a"
    echo "  c"
    echo ""
    echo "Arquivos disponiveis:"
    echo ""

    for i in "${!OPTIONS[@]}"; do
      local mark=" "
      [[ "${SELECTED[$i]}" == "1" ]] && mark="x"
      printf '  [%s] %2d) %s\n' "$mark" "$((i+1))" "${OPTIONS[$i]}"
    done

    echo ""
    read -r -p "> " ANSWER

    case "$ANSWER" in
      q|Q)
        echo "Cancelado."
        exit 0
        ;;
      c|C)
        CHOSEN=()
        for i in "${!OPTIONS[@]}"; do
          if [[ "${SELECTED[$i]}" == "1" ]]; then
            CHOSEN+=("${OPTIONS[$i]}")
          fi
        done
        if [[ "${#CHOSEN[@]}" -eq 0 ]]; then
          echo "Nenhum arquivo selecionado."
          sleep 1
          continue
        fi
        return 0
        ;;
      a|A)
        for i in "${!SELECTED[@]}"; do SELECTED[$i]=1; done
        ;;
      l|L)
        for i in "${!SELECTED[@]}"; do SELECTED[$i]=0; done
        ;;
      "")
        ;;
      *)
        for item in $ANSWER; do
          if [[ "$item" =~ ^[0-9]+$ ]]; then
            idx=$((item-1))
            if (( idx >= 0 && idx < ${#OPTIONS[@]} )); then
              if [[ "${SELECTED[$idx]}" == "1" ]]; then
                SELECTED[$idx]=0
              else
                SELECTED[$idx]=1
              fi
            else
              echo "Numero invalido: $item"
              sleep 1
            fi
          else
            echo "Entrada invalida: $item"
            sleep 1
          fi
        done
        ;;
    esac
  done
}

show_remote_file_box() {
  local site="$1"

  print_box_header "REMOTE CLIPPER: $REMOTE_NGINX_AVAILABLE/$site"

  remote "sudo cat '$REMOTE_NGINX_AVAILABLE/$site'" | sed 's/\r$//'

  printf '\n'
  print_line
  printf '\n'
}

send_one_site() {
  local site="$1"
  local local_file="$LOCAL_SITES_DIR/$site"

  [[ -f "$local_file" ]] || die "arquivo nao existe: $local_file"

  echo ""
  echo "Enviando: $site"
  echo "Origem local:  $local_file"
  echo "Destino remoto: $REMOTE_USER@$REMOTE_HOST:$REMOTE_NGINX_AVAILABLE/$site"

  rsync -avz -e "ssh -i $SSH_KEY" "$local_file" "$REMOTE_USER@$REMOTE_HOST:/tmp/$site"

  remote "
    set -e
    sudo cp '/tmp/$site' '$REMOTE_NGINX_AVAILABLE/$site'
    sudo nginx -t
    sudo systemctl reload nginx
  "

  echo "OK: $site enviado e Nginx recarregado."
}

# Uso direto:
#   ./03_IMPORTANTE_nginx_push_site.sh admin.sindicatto.com
#   ./03_IMPORTANTE_nginx_push_site.sh admin.sindicatto.com api.sindicatto.com
#
# Uso interativo:
#   ./03_IMPORTANTE_nginx_push_site.sh

if [[ "$#" -gt 0 ]]; then
  CHOSEN=("$@")
else
  select_sites_interactive
fi

echo ""
echo "Arquivos selecionados:"
for site in "${CHOSEN[@]}"; do
  echo "  - $site"
done

echo ""
read -r -p "Confirmar envio desses arquivos? [s/N] " CONFIRM
case "$CONFIRM" in
  s|S|sim|SIM|Sim) ;;
  *) echo "Cancelado."; exit 0 ;;
esac

for site in "${CHOSEN[@]}"; do
  send_one_site "$site"
done

echo ""
echo "Conteudo remoto confirmado:"
for site in "${CHOSEN[@]}"; do
  show_remote_file_box "$site"
done

echo "Tudo certo."
