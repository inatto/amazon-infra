#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/34.199.171.33/

set -euo pipefail

APACHE_ROOT="/opt/bitnami/apache"
VHOST_DIR="${APACHE_ROOT}/conf/vhosts"
BACKUP_DIR="${VHOST_DIR}/backup"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
BACKUP_RUN_DIR="${BACKUP_DIR}/before-farm-bncert-${TIMESTAMP}"

echo "Criando backup dos VirtualHosts atuais..."
sudo mkdir -p "${BACKUP_RUN_DIR}"

sudo find "${VHOST_DIR}" \
    -maxdepth 1 \
    -type f \
    -name "*.conf" \
    ! -name "farm.inatto.com-vhost.conf" \
    ! -name "farm.inatto.com-https-vhost.conf" \
    -exec cp -a {} "${BACKUP_RUN_DIR}/" \;

echo
echo "Backup criado em:"
echo "${BACKUP_RUN_DIR}"

echo
echo "Arquivos protegidos:"
sudo find "${BACKUP_RUN_DIR}" \
    -maxdepth 1 \
    -type f \
    -printf "%f\n" \
    | sort

echo
echo "Executando o Bitnami Certificate Tool..."
sudo /opt/bitnami/bncert-tool

echo
echo "Restaurando os VirtualHosts anteriores, mantendo os arquivos do farm.inatto.com..."

sudo find "${BACKUP_RUN_DIR}" \
    -maxdepth 1 \
    -type f \
    -name "*.conf" \
    -exec cp -a {} "${VHOST_DIR}/" \;

echo
echo "Validando a configuração do Apache..."

if ! sudo "${APACHE_ROOT}/bin/apachectl" -t; then
    echo
    echo "ERRO: a configuração do Apache ficou inválida."
    echo "O Apache não será reiniciado."
    echo "Backup disponível em:"
    echo "${BACKUP_RUN_DIR}"
    exit 1
fi

echo
echo "VirtualHosts carregados:"
sudo "${APACHE_ROOT}/bin/httpd" -S

echo
echo "Reiniciando o Apache..."
sudo /opt/bitnami/ctlscript.sh restart apache

echo
echo "Concluído."
echo "Os VirtualHosts anteriores foram restaurados."
echo "Os arquivos do farm.inatto.com foram mantidos como gerados pelo bncert-tool."