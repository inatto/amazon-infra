# Publicação de domínio

Os scripts deste diretório cuidam somente de DNS, Nginx, SSL e instalação dos serviços systemd. O envio e a inicialização da aplicação pertencem ao deploy da própria aplicação.

Exemplo para `orbital.anpprev.org`:

```bash
cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy

./01-testar-dns.sh ../domains/orbital.anpprev.org.conf
./02-copiar-nginx-do-servidor.sh ../domains/orbital.anpprev.org.conf
./03-configurar-nginx.sh ../domains/orbital.anpprev.org.conf
./04-instalar-ssl.sh ../domains/orbital.anpprev.org.conf
./05-instalar-servicos.sh ../domains/orbital.anpprev.org.conf
```

O passo 03 pode deixar o domínio respondendo `502` enquanto a aplicação ainda não estiver rodando. Isso é esperado.

Não apague `temp-remover-depois-se-nao-precisar-mais/` até confirmar que o fluxo novo funciona.

