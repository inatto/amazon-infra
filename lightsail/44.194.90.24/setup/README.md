# Setup básico da instância 44.194.90.24

Execute os scripts localmente no WSL. Cada script abre SSH e executa os comandos na instância.

```bash
cd /home/daniel/Code/infra/amazon-infra/lightsail/44.194.90.24/setup

./01-testar-acesso-ssh.sh

./02-atualizar-apt.sh

./03-instalar-utilitarios.sh

./04-validar-utilitarios.sh

./05-instalar-ferramentas.sh

./06-validar-ferramentas.sh
```

O passo 05 instala somente o necessário para:

- deploy por rsync;
- APIs Python/FastAPI com ambiente virtual;
- aplicações Astro com Node.js e npm;
- Nginx;
- Certbot com integração ao Nginx;
- serviços systemd já existentes no Ubuntu.

Os deploys dos próprios aplicativos continuam responsáveis por criar `.venv`, instalar `requirements.txt`, executar `npm ci`, gerar o build e reiniciar os serviços.
