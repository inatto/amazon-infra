#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT/deploy/configurar-dominio-passo-a-passo.sh"

bash -n "$SOURCE"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/deploy" "$TMP/ec2/127.0.0.1/domains"
cp "$SOURCE" "$TMP/deploy/"
CONFIG="$TMP/ec2/127.0.0.1/domains/teste.exemplo.conf"
printf 'REMOTE_HOST=127.0.0.1\n' > "$CONFIG"

for number in 01 02 03 04 05 06; do
  case "$number" in
    01) name='testar-dns' ;;
    02) name='configurar-nginx' ;;
    03) name='instalar-ssl' ;;
    04) name='instalar-servicos' ;;
    05) name='copiar-configuracoes-do-servidor' ;;
    06) name='coletar-informacoes-do-servidor' ;;
  esac
  cat > "$TMP/deploy/$number-$name.sh" <<MOCK
#!/usr/bin/env bash
set -Eeuo pipefail
[[ "\$1" == "$CONFIG" ]]
printf '%s\n' '$number' >> "$TMP/executados.log"
MOCK
  chmod +x "$TMP/deploy/$number-$name.sh"
done

printf '\n\n\n\n\n\n' | "$TMP/deploy/configurar-dominio-passo-a-passo.sh" "$CONFIG" >/dev/null
[[ "$(paste -sd, "$TMP/executados.log")" == '01,02,03,04,05,06' ]]

# Confirma que uma falha interrompe o fluxo e impede passos posteriores.
cat > "$TMP/deploy/03-instalar-ssl.sh" <<MOCK
#!/usr/bin/env bash
exit 9
MOCK
chmod +x "$TMP/deploy/03-instalar-ssl.sh"
rm -f "$TMP/executados.log"
set +e
printf '\n\n\n\n\n\n' | "$TMP/deploy/configurar-dominio-passo-a-passo.sh" "$CONFIG" >/dev/null 2>&1
status=$?
set -e
[[ $status -eq 9 ]]
[[ "$(paste -sd, "$TMP/executados.log")" == '01,02' ]]

echo 'OK: fluxo guiado confirma passos, executa 01-06 em ordem e para no primeiro erro.'
