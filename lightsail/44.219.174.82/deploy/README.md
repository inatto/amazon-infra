# Publicação de domínio

Os scripts deste diretório cuidam somente de DNS, Nginx, SSL e instalação dos serviços systemd. O envio e a inicialização da aplicação pertencem ao deploy da própria aplicação.

## Preparar `station.anpprev.org`

Crie no DNS de `anpprev.org` um registro `A`:

```text
Nome: station
IPv4: 44.219.174.82
Proxy: desativado durante a primeira publicação
```

As portas reservadas para o `station-app` são:

- Astro: `4002`;
- API: `8002`.

O domínio pode ser preparado antes de a aplicação estar rodando. Execute:

```bash
cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy

./01-testar-dns.sh ../domains/station.anpprev.org.conf
./02-copiar-nginx-do-servidor.sh ../domains/station.anpprev.org.conf
./03-configurar-nginx.sh ../domains/station.anpprev.org.conf
./04-instalar-ssl.sh ../domains/station.anpprev.org.conf
```

O passo 03 solicita a confirmação `PUBLICAR`. Não execute o passo 05: a instalação dos serviços pertence ao deploy do `station-app`.

Enquanto o Astro e a API não estiverem rodando, o domínio pode responder `502 Bad Gateway`. O certificado e o cabeçalho do Nginx já devem estar corretos:

```bash
curl -sSI https://station.anpprev.org/
curl -sSI https://station.anpprev.org/ | grep -i '^x-site-app: station-app'
```

Depois de publicar o `station-app`, valide:

```bash
ssh -i /home/daniel/amazon.ssh ubuntu@44.219.174.82 \
  'curl -fsSI http://127.0.0.1:4002/ | head; curl -fsS http://127.0.0.1:8002/health'

curl -fsSI https://station.anpprev.org/
curl -fsS https://station.anpprev.org/api/health
```

## Publicar `previa.anpprev.org`

Antes de executar os scripts, crie no DNS de `anpprev.org` um registro `A`:

```text
Nome: previa
IPv4: 44.219.174.82
Proxy: desativado durante a primeira publicação
```

Não é necessário que as aplicações estejam rodando para preparar o domínio. As portas reservadas são:

- `site-inst/anpprev` Astro: `4100`;
- API base compartilhada do `site-inst`: `8003`.

Se quiser conferir o estado atual das portas, execute:

```bash
ssh -i /home/daniel/amazon.ssh ubuntu@44.219.174.82 \
  'curl -fsSI http://127.0.0.1:4100/ | head; curl -fsS http://127.0.0.1:8003/health'
```

Se esses testes falharem agora, continue normalmente. O Nginx e o SSL podem ser preparados antes da publicação do tenant e da API.

Depois execute, na ordem:

```bash
cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy

./01-testar-dns.sh ../domains/previa.anpprev.org.conf
./02-copiar-nginx-do-servidor.sh ../domains/previa.anpprev.org.conf
./03-configurar-nginx.sh ../domains/previa.anpprev.org.conf
./04-instalar-ssl.sh ../domains/previa.anpprev.org.conf
```

O passo 03 solicita a confirmação `PUBLICAR`. Não é necessário executar o passo 05: os serviços serão instalados pelo deploy do próprio `site-inst`.

Enquanto a aplicação não estiver rodando, o domínio pode responder `502 Bad Gateway`. Isso é esperado e não significa erro no DNS, Nginx ou SSL.

Valide a infraestrutura ao final:

```bash
curl -sSI https://previa.anpprev.org/
curl -sSI https://previa.anpprev.org/ | grep -i '^x-site-app: site-inst-anpprev'
```

Antes de subir a aplicação, o resultado esperado pode ser HTTP `502`, mas o certificado deve ser válido e o cabeçalho deve ser `X-Site-App: site-inst-anpprev`.

Depois de publicar o tenant na porta `4100` e a API base na porta `8003`, valide:

```bash
ssh -i /home/daniel/amazon.ssh ubuntu@44.219.174.82 \
  'curl -fsSI http://127.0.0.1:4100/ | head; curl -fsS http://127.0.0.1:8003/health'

curl -fsSI https://previa.anpprev.org/
curl -fsS https://previa.anpprev.org/api/health
```

Nesse momento, o site e `/api/health` devem responder sem necessidade de alterar novamente o Nginx ou o certificado.

## Exemplo para outro domínio

Substitua o arquivo `.conf` nos mesmos scripts. O passo 03 pode deixar o domínio respondendo `502` enquanto a aplicação ainda não estiver rodando.

Não apague `temp-remover-depois-se-nao-precisar-mais/` até confirmar que o fluxo novo funciona.
