# Amazon Infra Monitor

Painel local e remoto de observabilidade do servidor.

- Web Astro: `http://127.0.0.1:4005`
- API FastAPI: `http://127.0.0.1:8005`
- Versão: `0.0.1`
- Banco: configuração Oracle pronta, desativada por padrão.

## Teste local

```bash
cd monitor-app/deploy/local
./setup.sh
```

O processo permanece em primeiro plano e pode ser encerrado com `Ctrl+C`.

## Publicação

A configuração de infraestrutura para `monitor.inatto.com` está em:

```text
../ec2/52.67.135.170/domains/monitor.inatto.com.conf
```

Teste localmente antes de executar qualquer deploy remoto.
