# Amazon Infra Control

Painel Web/API para observar e administrar a EC2 principal.

- Web: `https://monitor.inatto.com` (`127.0.0.1:4005`)
- API: `127.0.0.1:8005`
- Visão geral: CPU, memória, disco, uptime, portas, endpoints e grupos monitorados.
- Domínios & rotas: lê `/etc/nginx/sites-available`, mostra SSL, redirects e `proxy_pass`.
- Serviços: lê systemd real da EC2.
- Administração: cria/atualiza redirects de domínio com `nginx -t`, reload, rollback e SSL opcional via Certbot.

## Segurança

Alterações exigem `INFRA_ADMIN_TOKEN`. O deploy preserva o token remoto existente ou gera um novo na primeira instalação e o imprime no terminal. A API roda como `ubuntu`; apenas o helper `/usr/local/sbin/amazon-infra-nginx` possui sudo sem senha e ele valida domínio/destino antes de qualquer alteração.

## Deploy remoto

```bash
cd /home/daniel/Code/infra/amazon-infra/monitor-app/deploy/remote && \
./setup.sh
```

Ao terminar, copie o `INFRA_ADMIN_TOKEN` exibido e use-o no painel em `https://monitor.inatto.com`.
