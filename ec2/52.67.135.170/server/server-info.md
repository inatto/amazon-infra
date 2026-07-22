# Informações do servidor

> Gerado automaticamente. Os valores representam o momento da coleta.

| Item | Valor |
|---|---|
| Coletado em | `2026-07-22T01:54:04+00:00` |
| Hostname | `ip-172-31-23-158.sa-east-1.compute.internal` |
| Sistema | `Ubuntu 24.04.4 LTS` |
| Kernel | `6.17.0-1019-aws` |
| Arquitetura | `x86_64` |
| Uptime | `up 10 hours, 19 minutes` |
| Inicializado em | `2026-07-21 15:34:32` |
| Carga 1/5/15 min | `0.08 0.08 0.04` |
| CPUs lógicas | `2` |

## Memória e swap

```text
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       810Mi       437Mi        10Mi       875Mi       1.1Gi
Swap:          2.0Gi       4.0Ki       2.0Gi
```

## Disco

```text
Filesystem      Type      Size  Used Avail Use% Mounted on
/dev/root       ext4       29G  5.6G   23G  20% /
efivarfs        efivarfs  128K  3.3K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16 ext4      881M  163M  657M  20% /boot
/dev/nvme0n1p15 vfat      105M  6.2M   99M   6% /boot/efi
```

## Inodes

```text
Filesystem      Inodes IUsed IFree IUse% Mounted on
/dev/root         3.7M  165K  3.5M    5% /
efivarfs             0     0     0     - /sys/firmware/efi/efivars
/dev/nvme0n1p16    58K   605   57K    2% /boot
/dev/nvme0n1p15      0     0     0     - /boot/efi
```

## Processos

```text
Total: 129
 01:54:04 up 10:19,  2 users,  load average: 0.08, 0.08, 0.04
```

## Rede

### Endereços IP

```text
172.31.23.158 
```

### Portas em escuta

```text
Netid State  Recv-Q Send-Q      Local Address:Port Peer Address:PortProcess                                                                                
udp   UNCONN 0      0               127.0.0.1:323       0.0.0.0:*                                                                                          
udp   UNCONN 0      0              127.0.0.54:53        0.0.0.0:*                                                                                          
udp   UNCONN 0      0           127.0.0.53%lo:53        0.0.0.0:*                                                                                          
udp   UNCONN 0      0      172.31.23.158%ens5:68        0.0.0.0:*                                                                                          
udp   UNCONN 0      0                   [::1]:323          [::]:*                                                                                          
tcp   LISTEN 0      4096           127.0.0.54:53        0.0.0.0:*                                                                                          
tcp   LISTEN 0      511               0.0.0.0:80        0.0.0.0:*                                                                                          
tcp   LISTEN 0      2048            127.0.0.1:8002      0.0.0.0:*    users:(("python",pid=32978,fd=3),("python",pid=32977,fd=3),("uvicorn",pid=32926,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8001      0.0.0.0:*    users:(("python",pid=31822,fd=3),("python",pid=31821,fd=3),("uvicorn",pid=31816,fd=3))
tcp   LISTEN 0      4096              0.0.0.0:22        0.0.0.0:*                                                                                          
tcp   LISTEN 0      511             127.0.0.1:4002      0.0.0.0:*    users:(("node",pid=32983,fd=21))                                                      
tcp   LISTEN 0      511             127.0.0.1:4001      0.0.0.0:*    users:(("node",pid=31877,fd=21))                                                      
tcp   LISTEN 0      4096        127.0.0.53%lo:53        0.0.0.0:*                                                                                          
tcp   LISTEN 0      511               0.0.0.0:443       0.0.0.0:*                                                                                          
tcp   LISTEN 0      511                  [::]:80           [::]:*                                                                                          
tcp   LISTEN 0      4096                 [::]:22           [::]:*                                                                                          
tcp   LISTEN 0      511                  [::]:443          [::]:*                                                                                          
```

## Nginx

### Validação

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Estado

```text
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: active (running) since Tue 2026-07-21 15:39:34 UTC; 10h ago
       Docs: man:nginx(8)
   Main PID: 2730 (nginx)
      Tasks: 3 (limit: 2209)
     Memory: 14.8M (peak: 22.3M)
        CPU: 18.503s
     CGroup: /system.slice/nginx.service
             ├─ 2730 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─33288 "nginx: worker process"
             └─33289 "nginx: worker process"

Jul 21 18:30:03 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 21 18:36:04 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 21 18:36:05 ip-172-31-23-158 nginx[17740]: 2026/07/21 18:36:05 [notice] 17740#17740: signal process started
Jul 21 18:36:05 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 21 18:42:52 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 21 18:42:52 ip-172-31-23-158 nginx[19390]: 2026/07/21 18:42:52 [notice] 19390#19390: signal process started
Jul 21 18:42:52 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 22 01:52:49 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 22 01:52:49 ip-172-31-23-158 nginx[33120]: 2026/07/22 01:52:49 [notice] 33120#33120: signal process started
Jul 22 01:52:49 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
```

## Serviços das aplicações

### `inst-app-anpprev-api.service`

| Propriedade | Valor |
|---|---|
| Ativo | `inactive` |
| Habilitado | `enabled` |

```text
○ inst-app-anpprev-api.service - inst-app-anpprev API FastAPI
     Loaded: loaded (/etc/systemd/system/inst-app-anpprev-api.service; enabled; preset: enabled)
     Active: inactive (dead)
```

### `inst-app-anpprev-web.service`

| Propriedade | Valor |
|---|---|
| Ativo | `inactive` |
| Habilitado | `enabled` |

```text
○ inst-app-anpprev-web.service - inst-app-anpprev Astro Web
     Loaded: loaded (/etc/systemd/system/inst-app-anpprev-web.service; enabled; preset: enabled)
     Active: inactive (dead)
```

