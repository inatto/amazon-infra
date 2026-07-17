# Domínios, DNS, Nginx e SSL

Esta pasta cuida somente da exposição pública dos domínios. O envio, build,
início, reinício e rollback das aplicações pertencem ao repositório de cada
aplicação.

## Orbital

O domínio e o Nginx podem ser preparados antes da aplicação. Para o teste final,
o `orbital-app` deverá estar publicado em:

```text
/home/ubuntu/apps/orbital-app
```

| Serviço | Endereço interno remoto |
|---|---|
| Astro | `127.0.0.1:4001` |
| API | `127.0.0.1:8001` |

As portas acompanham o padrão documentado em
`../../../../../docs/portas-aplicacoes.md`
e precisam ser as mesmas definidas no `.env` do `orbital-app`.

## Passo a passo: orbital.anpprev.org

### 1. Criar o DNS

No provedor DNS de `anpprev.org`, crie:

```text
Tipo: A
Nome: orbital
Destino: 44.219.174.82
```

O `sind-infra` verifica o DNS, mas não altera o provedor automaticamente.

### 2. Verificar o DNS

```bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
./01-dns-check.sh configs/orbital.anpprev.org.conf
```

### 3. Fazer backup do Nginx

```bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
./02-nginx-backup.sh configs/orbital.anpprev.org.conf
```

O script faz somente um `rsync` completo de `/etc/nginx/` do servidor para:

```text
sind-amazon/lightsail/44.219.174.82/server/etc/nginx/
```

O espelho inclui `sites-available`, `sites-enabled` e os demais arquivos do
Nginx. Nada é alterado no servidor.

### 4. Publicar a configuração Nginx

```bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
./03-nginx-publish.sh configs/orbital.anpprev.org.conf
```

O script usa o espelho local como estado anterior, gera a configuração em um
arquivo temporário, publica somente esse domínio, executa `nginx -t` e recarrega
o Nginx. Se a alteração falhar, restaura automaticamente a versão que veio no
`rsync`. Depois do sucesso, sincroniza novamente `/etc/nginx/` para o espelho.
Digite `PUBLICAR` quando solicitado.

O roteamento será:

```text
https://orbital.anpprev.org/      -> 127.0.0.1:4001
https://orbital.anpprev.org/api/ -> 127.0.0.1:8001
```

### 5. Emitir SSL

```bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
./04-ssl-issue.sh configs/orbital.anpprev.org.conf
```

O Certbot emite ou reutiliza o certificado e o script republica a configuração
definitiva com HTTPS.

### 6. Testar tudo

```bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
./05-domain-test.sh configs/orbital.anpprev.org.conf
```

O teste confirma Nginx, HTTPS, identificação do site e resposta dos upstreams.
Ele não inicia a aplicação.

## Restaurar o Nginx

Para reenviar ao servidor a versão que estiver no espelho local:

```bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains
./06-nginx-restore.sh configs/orbital.anpprev.org.conf
```

A restauração altera apenas o domínio selecionado, respeita o estado local de
`sites-enabled`, executa `nginx -t` e recarrega o Nginx. Para voltar a uma
versão anterior, restaure primeiro o arquivo pelo Git e depois execute o script.

## Arquivos marcados para remoção

Arquivos antigos ou substituídos recebem o sufixo literal ` [REMOVE]`. Eles
foram preservados apenas para comparação e podem ser apagados depois que este
fluxo for validado no servidor.
