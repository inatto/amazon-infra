# Publicação de orbital.anpprev.org

Execute os scripts localmente no WSL. Eles acessam a instância `44.194.90.24` por SSH.

## Pré-requisitos

- Setup da instância concluído até `06-validar-ferramentas.sh`.
- Porta 22, 80 e 443 liberadas no Lightsail.
- Registro DNS A de `orbital.anpprev.org` apontando para `44.194.90.24`.
- Chave SSH em `/home/daniel/amazon.ssh`.

## Infraestrutura

```bash
cd /home/daniel/Code/infra/amazon-infra/lightsail/44.194.90.24/deploy

./01-testar-dns.sh ../domains/orbital.anpprev.org.conf

./02-copiar-nginx-do-servidor.sh ../domains/orbital.anpprev.org.conf

./03-configurar-nginx.sh ../domains/orbital.anpprev.org.conf

./05-instalar-servicos.sh ../domains/orbital.anpprev.org.conf
```

No passo 03, digite `PUBLICAR`.

No passo 05, digite `INSTALAR`.

## Aplicação

Antes do deploy do Orbital, confirme que os scripts em `orbital-app/deploy/remote` usam:

```text
ubuntu@44.194.90.24
```

Depois, na raiz do projeto Orbital:

```bash
cd /home/daniel/Code/orgs/orbital-app

./deploy/remote/setup.sh

./deploy/remote/test.sh

./deploy/remote/start.sh
```

Os arquivos `.env` e o Oracle Wallet não são enviados pelo rsync e devem existir no novo servidor.

## SSL

Depois que o DNS e o Nginx estiverem funcionando:

```bash
cd /home/daniel/Code/infra/amazon-infra/lightsail/44.194.90.24/deploy

./04-instalar-ssl.sh ../domains/orbital.anpprev.org.conf
```

## Validação

```bash
curl -I http://orbital.anpprev.org

curl -I https://orbital.anpprev.org

curl https://orbital.anpprev.org/api/health
```
