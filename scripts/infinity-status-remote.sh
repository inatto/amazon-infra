#!/usr/bin/env bash
interval=$1
base=/opt/dlami/nvme/infinitetalk-test
if [ "$interval" != 0 ]; then
  printf '\033[?1049h\033[?25l'
  trap 'printf "\033[?25h\033[?1049l"' EXIT
  trap 'exit 130' INT TERM
fi
while :; do
  panel=$(
  printf 'INFINITALK | %s | atualizacao: %ss | Ctrl+C para sair\n' "$(date '+%H:%M:%S %Z')" "$interval"
  echo 'Instancia de teste: i-03dc82dd72e2ce144 | L40S | ~US$3,004/h'
  if [ -s "$base/status.txt" ]; then
    printf 'STATUS: '
    cat "$base/status.txt"
  fi
  echo
  echo 'ANDAMENTO ATUAL:'
  # Match only the active Python worker, not wrapper shells whose command text
  # happens to contain the generation command for the whole queue.
  test_pid=$(pgrep -f '^[^ ]*python[^ ]* +generate_infinitetalk\.py' | head -n 1)
  if [ -n "$test_pid" ]; then
    process_cmd=$(tr '\0' ' ' < "/proc/$test_pid/cmdline" 2>/dev/null)
    input_json=$(printf '%s\n' "$process_cmd" | sed -n 's/.*--input_json[[:space:]]\+\([^[:space:]]\+\).*/\1/p')
    save_file=$(printf '%s\n' "$process_cmd" | sed -n 's/.*--save_file[[:space:]]\+\([^[:space:]]\+\).*/\1/p')
    clip_id=$(basename "${input_json:-desconhecido}" | sed 's/-.*//')
    case "$input_json" in
      /*) input_json_path=$input_json ;;
      *) input_json_path="$base/InfiniteTalk/$input_json" ;;
    esac
    prompt=$(python3 -c 'import json,sys; print(" ".join(str(json.load(open(sys.argv[1])).get("prompt", "")).split()))' "$input_json_path" 2>/dev/null)
    [ -n "$input_json" ] && printf '  CLIPE: %s\n  JSON/PROMPT: %s\n' "$clip_id" "$input_json"
    [ -n "$save_file" ] && printf '  SAIDA: %s.mp4\n' "$save_file"
    if [ -n "$prompt" ]; then
      prompt_suffix=
      [ "${#prompt}" -gt 240 ] && prompt_suffix=...
      printf '  PROMPT: %.240s%s\n' "$prompt" "$prompt_suffix"
    fi

    full_log=$(tr '\r' '\n' < "$base/test.log" 2>/dev/null)
    if [ -n "$clip_id" ]; then
      clip_log=$(printf '%s\n' "$full_log" | awk -v marker="$clip_id START" 'index($0,marker){out=""; found=1} found{out=out $0 ORS} END{printf "%s",out}')
    else
      clip_log=$full_log
    fi
    last_stage=$(printf '%s\n' "$clip_log" | tail -c 12000)
    if printf '%s' "$last_stage" | grep -qE '^ *(0|25|50|75|100)%\||Sampling'; then
      stage='GERANDO FRAMES'
    elif printf '%s' "$last_stage" | grep -q 'Creating WanModel'; then
      stage='CARREGANDO WAN 14B NA RAM'
    elif printf '%s' "$last_stage" | grep -q 'models_clip'; then
      stage='CARREGANDO CLIP'
    elif printf '%s' "$last_stage" | grep -q 'models_t5'; then
      stage='CARREGANDO T5'
    else
      stage='INICIALIZANDO'
    fi
    echo "  ETAPA: $stage"
    block_current=$(printf '%s\n' "$clip_log" | grep -c "^  0%|" || true); if [ "$block_current" -gt 0 ]; then step_pct=$(printf '%s\n' "$clip_log" | sed -n "s/^ *\([0-9]\+\)%.*/\1/p" | tail -n 1); step_pct=${step_pct:-0}; printf "  BLOCO %s/6 | PASSO %s/4 (%s%% do bloco) | TOTAL: 375 frames\n" "$block_current" "$((step_pct/25))" "$step_pct"; else echo "  BLOCO 0/6 | PASSOS ainda nao iniciados | FRAMES 0/375"; fi
    ps -p "$test_pid" -o pid=,stat=,etime=,%cpu=,%mem=,rss= | awk '{printf "  PID %s | estado %s | tempo %s | CPU %s%% | RAM %.2f GB\n",$1,$2,$3,$4,$6/1e6}'
    awk '/^rchar:/{printf "  Dados lidos pelo processo: %.2f GB\n",$2/1e9}' "/proc/$test_pid/io" 2>/dev/null
  elif find "$base/InfiniteTalk" -maxdepth 2 -type f -name 'foi-deus-l40s-8s*.mp4' -print -quit | grep -q .; then
    echo '  ETAPA: CONCLUIDO — MP4 criado'
  elif grep -q 'Traceback' "$base/test.log" 2>/dev/null; then
    echo '  ETAPA: ERRO — veja [test] abaixo'
  else
    echo '  ETAPA: AGUARDANDO — nenhum teste ativo'
  fi
  echo
  echo 'PROCESSOS — download / instalacao / geracao:'
  pgrep -af 'hf download|uv pip|python.*generate_infinitetalk|apt-get|dpkg' || echo 'Nenhum processo ativo.'
  echo
  echo 'MODELOS — GB decimais no disco (inclui parciais):'
  du -sb "$base/InfiniteTalk/weights/"* 2>/dev/null | awk '{printf "  %7.2f GB  %s\n",$1/1e9,$2}'
  echo '  Wan: total esperado 82,27 GB; InfiniteTalk single: 9,95 GB.'
  echo
  echo 'GPU — uso %, VRAM usada / total:'
  nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader
  echo 'GPU em 0% nao informa percentual do teste; pode estar aguardando ou sem processo.'
  echo
  echo 'RAM E DISCO NVMe:'
  free -h | head -n 2
  df -h "$base" | tail -n 1
  echo
  echo 'ULTIMAS MENSAGENS — nao equivalem a um percentual geral:'
  for name in install extras validation test; do
    printf '\n[%s]\n' "$name"
    if [ -f "$base/$name.log" ]; then
      tail -c 2500 "$base/$name.log" | tr '\r' '\n' | tail -n 4
    else
      echo 'Sem log desta etapa.'
    fi
  done
  if [ -r /run/systemd/shutdown/scheduled ]; then
    deadline=$(sed -n 's/^USEC=//p' /run/systemd/shutdown/scheduled)
    printf '\nDesligamento: %s\n' "$(date -d "@$((deadline/1000000))" '+%H:%M:%S %Z')"
  fi
  )
  if [ "$interval" = 0 ]; then
    printf '%s\n' "$panel"
    break
  fi
  frame=$(printf '%s\n' "$panel" | sed $'s/$/\033[K/')
  printf '\033[H%s\033[J' "$frame"
  sleep "$interval"
done
