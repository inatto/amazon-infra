# Publicação no servidor 52.67.135.170

Execute os scripts localmente no WSL. Os passos 01 a 04 recebem o arquivo do domínio. O passo 05 é geral e não recebe parâmetro.

## Pré-requisitos

- Setup da instância concluído até `06-validar-ferramentas.sh`.
- Portas 22, 80 e 443 liberadas na EC2.
- Registro DNS A do domínio apontando para `52.67.135.170`.
- Chave SSH em `/home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/core/inatto01-sp.pem`.

## Fluxo de infraestrutura

Exemplo para `painel.anpprev.org`:

```bash
cd /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/deploy

./01-testar-dns.sh ../domains/painel.anpprev.org.conf

./02-configurar-nginx.sh ../domains/painel.anpprev.org.conf

./03-instalar-ssl.sh ../domains/painel.anpprev.org.conf

./04-instalar-servicos.sh ../domains/painel.anpprev.org.conf

./05-copiar-configuracoes-do-servidor.sh
```

No passo 02, digite `PUBLICAR` quando solicitado.

No passo 04, digite `INSTALAR` quando solicitado.

## Passo 05: cópia final geral

O último passo não recebe domínio. Ele copia para `server/`:

```text
/etc/nginx/                         -> server/etc/nginx/
serviços de domains/*.conf             -> server/etc/systemd/system/
renovações dos domínios cadastrados    -> server/etc/letsencrypt/renewal/
```

O Nginx é copiado por completo, incluindo `nginx.conf`, `conf.d`, `sites-available`, `sites-enabled` e `snippets`.

Não são copiadas aplicações, `.env`, Oracle Wallet, bancos, uploads, certificados SSL nem chaves privadas.
