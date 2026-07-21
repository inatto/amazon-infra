# Configurar swap de 2 GB com segurança e sem recriar se já estiver ativa

set -euo pipefail

SWAP_FILE="/swapfile"
SWAP_SIZE="2G"
SWAPPINESS="10"

# Cria a swap somente se o arquivo ainda não existir.
if [ ! -f "$SWAP_FILE" ]; then
  sudo fallocate -l "$SWAP_SIZE" "$SWAP_FILE"
  sudo chmod 600 "$SWAP_FILE"
  sudo mkswap "$SWAP_FILE"
fi

# Garante a permissão correta.
sudo chmod 600 "$SWAP_FILE"

# Ativa somente se ainda não estiver ativa.
if ! sudo swapon --show=NAME --noheadings | grep -qx "$SWAP_FILE"; then
  sudo swapon "$SWAP_FILE"
fi

# Registra no fstab somente se ainda não estiver registrado.
if ! grep -qE '^[[:space:]]*/swapfile[[:space:]]+' /etc/fstab; then
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# Configura o uso moderado da swap.
echo "vm.swappiness=$SWAPPINESS" \
  | sudo tee /etc/sysctl.d/99-swap.conf >/dev/null

sudo sysctl -p /etc/sysctl.d/99-swap.conf

# Validação final.
echo
free -h
echo
swapon --show
echo
grep -E '^[[:space:]]*/swapfile[[:space:]]+' /etc/fstab
echo
sysctl vm.swappiness