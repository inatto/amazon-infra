# Amazon Infra Control

Painel Web/API para observar e administrar a EC2 principal.

- Web: `https://monitor.inatto.com` (`127.0.0.1:4005`)
- API: `127.0.0.1:8005`
- Visão geral: CPU, memória, disco, uptime, portas, endpoints e grupos monitorados.
- Domínios & rotas: lê a pasta ativa de domínios da `amazon-infra`, mostra Nginx, SSL, redirects e `proxy_pass`.
- Serviços: lê o systemd real da EC2.
- Administração: cria/atualiza redirects com `nginx -t`, reload, rollback e SSL opcional via Certbot.

## Segurança

Alterações exigem `INFRA_ADMIN_TOKEN` em `apps/api/config/production/services.env.external` no servidor. O deploy não gera nem sobrescreve segredos. A API roda sem root; somente o helper Nginx restrito possui autorização sudo.

## Execução

Local:

```bash
monitor-app
```

Remoto:

```bash
remote-monitor-app
```

Não execute scripts de `deploy/` diretamente; os comandos globais são gerenciados pelo Dev Management.
