#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "ERRO: $*" >&2
  exit 1
}

if grep -Rqs '^SYSTEMD_SERVICES=' "$ROOT_DIR/ec2" "$ROOT_DIR/lightsail"; then
  fail 'amazon-infra ainda declara SYSTEMD_SERVICES'
fi

if find "$ROOT_DIR/deploy" "$ROOT_DIR/lightsail" -type f -name '*instalar-servicos.sh' -print -quit | grep -q .; then
  fail 'amazon-infra ainda possui instalador ativo de serviços das aplicações'
fi

grep -q 'SYSTEMD_SERVICES' "$ROOT_DIR/deploy/00-criar-configuracao-dominio.sh" \
  && fail 'gerador de domínio ainda cria SYSTEMD_SERVICES'
grep -q 'instalar-servicos' "$ROOT_DIR/deploy/configurar-dominio-passo-a-passo.sh" \
  && fail 'fluxo guiado ainda chama instalador de services'
if find "$ROOT_DIR/ec2" "$ROOT_DIR/lightsail" -type f -name '*.service' -print -quit | grep -q .; then
  fail 'amazon-infra ainda mantém unit de aplicação fora do próprio app'
fi

for script in \
  "$ROOT_DIR/deploy/05-copiar-configuracoes-do-servidor.sh" \
  "$ROOT_DIR/deploy/06-coletar-informacoes-do-servidor.sh" \
  "$ROOT_DIR/deploy/07-coletar-logs-do-servidor.sh" \
  "$ROOT_DIR/lightsail/44.194.90.24/deploy/06-copiar-configuracoes-do-servidor.sh"; do
  grep -q 'SYSTEMD_SERVICES' "$script" && fail "SYSTEMD_SERVICES residual em ${script#$ROOT_DIR/}"
  grep -Eq '/etc/systemd/system/\$service|systemctl (enable|start|stop|restart) .*\$service' "$script" \
    && fail "lifecycle/cópia de serviço residual em ${script#$ROOT_DIR/}"
done

echo 'OK: amazon-infra não declara, instala, copia ou gerencia lifecycle dos services das aplicações.'

MONITOR_REMOTE="$ROOT_DIR/apps/monitor-app/deploy/remote"
[[ -s "$MONITOR_REMOTE/systemd/amazon-infra-monitor-api.service" ]] || fail 'unit da API do monitor não pertence ao próprio app'
[[ -s "$MONITOR_REMOTE/systemd/amazon-infra-monitor-web.service" ]] || fail 'unit Web do monitor não pertence ao próprio app'
[[ -x "$MONITOR_REMOTE/setup-services.sh" ]] || fail 'setup-services.sh do monitor ausente ou não executável'

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/systemd"
cat > "$tmp/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
exec "$@"
MOCK
cat > "$tmp/bin/systemctl" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$SYSTEMCTL_LOG"
MOCK
chmod +x "$tmp/bin/sudo" "$tmp/bin/systemctl"

export SYSTEMCTL_LOG="$tmp/systemctl.log"
PATH="$tmp/bin:$PATH" SYSTEMD_UNIT_DIR="$tmp/systemd" "$MONITOR_REMOTE/setup-services.sh"
grep -qx 'daemon-reload' "$SYSTEMCTL_LOG" || fail 'primeira instalação não executou daemon-reload'
grep -qx 'enable amazon-infra-monitor-api.service amazon-infra-monitor-web.service' "$SYSTEMCTL_LOG" \
  || fail 'primeira instalação não habilitou os próprios services'
cmp -s "$MONITOR_REMOTE/systemd/amazon-infra-monitor-api.service" "$tmp/systemd/amazon-infra-monitor-api.service" \
  || fail 'unit da API não foi instalada corretamente'
cmp -s "$MONITOR_REMOTE/systemd/amazon-infra-monitor-web.service" "$tmp/systemd/amazon-infra-monitor-web.service" \
  || fail 'unit Web não foi instalada corretamente'

[[ "$(stat -c '%a' "$tmp/systemd/amazon-infra-monitor-api.service")" == '644' ]] || fail 'permissão da unit API não é 0644'
[[ "$(stat -c '%a' "$tmp/systemd/amazon-infra-monitor-web.service")" == '644' ]] || fail 'permissão da unit Web não é 0644'

chmod 0600 "$tmp/systemd/amazon-infra-monitor-api.service"
: > "$SYSTEMCTL_LOG"
PATH="$tmp/bin:$PATH" SYSTEMD_UNIT_DIR="$tmp/systemd" "$MONITOR_REMOTE/setup-services.sh"
! grep -qx 'daemon-reload' "$SYSTEMCTL_LOG" || fail 'deploy repetido executou daemon-reload sem alteração de unit'
grep -qx 'enable amazon-infra-monitor-api.service amazon-infra-monitor-web.service' "$SYSTEMCTL_LOG" \
  || fail 'deploy repetido deixou de garantir enable dos próprios services'
[[ "$(stat -c '%a' "$tmp/systemd/amazon-infra-monitor-api.service")" == '644' ]] || fail 'deploy repetido não corrigiu permissão da unit API'

echo 'OK: primeira instalação e deploy repetido do monitor são idempotentes.'
