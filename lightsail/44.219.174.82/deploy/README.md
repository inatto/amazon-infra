# Deploy do servidor/Nginx organizado

## Como usar sem erro

Nao cole o conteudo inteiro do `.sh` no terminal. Execute o arquivo:

```bash
cd deploy
./01_IMPORTANTE_status.sh
```

O erro `dirname: invalid option -- 'b'` aconteceu porque o conteudo do script foi colado direto no shell. Mesmo assim, os scripts novos ficaram mais robustos e usam `dirname --`, mas o uso certo é executar o arquivo.

## Ordem recomendada

```bash
cd deploy
./01_IMPORTANTE_status.sh
./02_IMPORTANTE_ports.sh
./05_IMPORTANTE_nginx_backup.sh
./03_IMPORTANTE_nginx_push_site.sh admin.sindicatto.com
./04_IMPORTANTE_nginx_reload.sh
./17_test_urls.sh https://admin.sindicatto.com
```

Para publicar domínios deste servidor, use o fluxo documentado em
`domains/README.md`. Ele separa DNS, backup, Nginx, SSL, teste e restore.

## Arquivos mais importantes

```text
00_IMPORTANTE_config.sh          -> IP, usuario, chave SSH e caminhos
01_IMPORTANTE_status.sh          -> status geral do servidor
02_IMPORTANTE_ports.sh           -> portas em uso
03_IMPORTANTE_nginx_push_site.sh -> envia 1 site Nginx e recarrega
04_IMPORTANTE_nginx_reload.sh    -> testa e recarrega Nginx
05_IMPORTANTE_nginx_backup.sh    -> baixa backup de /etc/nginx
06_IMPORTANTE_ssl_issue.sh       -> emite SSL Certbot
07_IMPORTANTE_cache_clear.sh     -> limpa cache/logs basicos
```

## Scripts que perguntam quando sem parametro

### Enviar site Nginx

Com parametro:

```bash
./03_IMPORTANTE_nginx_push_site.sh admin.sindicatto.com
```

Sem parametro, ele pergunta e mostra exemplos:

```bash
./03_IMPORTANTE_nginx_push_site.sh
```

### Emitir SSL

```bash
./06_IMPORTANTE_ssl_issue.sh admin.sindicatto.com
./06_IMPORTANTE_ssl_issue.sh sindicatto.com www.sindicatto.com
```

Sem parametro, ele pergunta os dominios.

### Habilitar/desabilitar site

```bash
./09_nginx_enable_site.sh admin.sindicatto.com
./10_nginx_disable_site.sh admin.sindicatto.com
```

Sem parametro, eles perguntam o nome do site.

### Testar URLs

```bash
./17_test_urls.sh https://admin.sindicatto.com https://api.sindicatto.com
```

Sem parametro, ele pergunta URLs. Se voce apertar Enter vazio, testa as URLs padrao.

## Portas padrao

```text
site-sinproprev-v2      -> 127.0.0.1:4321
orbital-app web         -> 127.0.0.1:4001
orbital-app API         -> 127.0.0.1:8001
station-app   -> 127.0.0.1:3126
sind-services API       -> 127.0.0.1:8000
site sinproprev.org.br  -> 127.0.0.1:3001
Nginx publico           -> 80 / 443
```

## AWS / Lightsail

Na Amazon/Lightsail, liberar somente:

```text
22  SSH
80  HTTP
443 HTTPS
```

Nao abrir 4321, 3126, 8000 nem 3001.
