# Informações do servidor

> Gerado automaticamente. Os valores representam o momento da coleta.

| Item | Valor |
|---|---|
| Coletado em | `2026-07-23T16:18:52-03:00` |
| Hostname | `ip-172-31-23-158.sa-east-1.compute.internal` |
| Sistema | `Ubuntu 24.04.4 LTS` |
| Kernel | `6.17.0-1019-aws` |
| Arquitetura | `x86_64` |
| Uptime | `up 2 days, 3 hours, 44 minutes` |
| Inicializado em | `2026-07-21 12:34:32` |
| Carga 1/5/15 min | `0.06 0.04 0.04` |
| CPUs lógicas | `2` |

## Memória e swap

```text
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       721Mi       209Mi       5.9Mi       1.1Gi       1.2Gi
Swap:          2.0Gi       629Mi       1.4Gi
```

## Disco

```text
Filesystem      Type      Size  Used Avail Use% Mounted on
/dev/root       ext4       29G  8.5G   20G  31% /
efivarfs        efivarfs  128K  3.3K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16 ext4      881M  163M  657M  20% /boot
/dev/nvme0n1p15 vfat      105M  6.2M   99M   6% /boot/efi
```

## Inodes

```text
Filesystem      Inodes IUsed IFree IUse% Mounted on
/dev/root         3.7M  186K  3.5M    6% /
efivarfs             0     0     0     - /sys/firmware/efi/efivars
/dev/nvme0n1p16    58K   605   57K    2% /boot
/dev/nvme0n1p15      0     0     0     - /boot/efi
```

## Processos

```text
Total: 133
 16:18:52 up 2 days,  3:44,  1 user,  load average: 0.06, 0.04, 0.04
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
tcp   LISTEN 0      2048            127.0.0.1:8002      0.0.0.0:*    users:(("python",pid=56830,fd=3),("python",pid=56829,fd=3),("uvicorn",pid=56764,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8001      0.0.0.0:*    users:(("python",pid=45640,fd=3),("python",pid=45639,fd=3),("uvicorn",pid=45634,fd=3))
tcp   LISTEN 0      4096              0.0.0.0:22        0.0.0.0:*                                                                                          
tcp   LISTEN 0      511             127.0.0.1:4002      0.0.0.0:*    users:(("node",pid=56819,fd=21))                                                      
tcp   LISTEN 0      511             127.0.0.1:4001      0.0.0.0:*    users:(("node",pid=45697,fd=21))                                                      
tcp   LISTEN 0      2048            127.0.0.1:8100      0.0.0.0:*    users:(("python",pid=40119,fd=3),("python",pid=40118,fd=3),("uvicorn",pid=40097,fd=3))
tcp   LISTEN 0      4096        127.0.0.53%lo:53        0.0.0.0:*                                                                                          
tcp   LISTEN 0      511               0.0.0.0:443       0.0.0.0:*                                                                                          
tcp   LISTEN 0      511             127.0.0.1:4100      0.0.0.0:*    users:(("node",pid=46975,fd=21))                                                      
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
     Active: active (running) since Tue 2026-07-21 12:39:34 -03; 2 days ago
       Docs: man:nginx(8)
   Main PID: 2730 (nginx)
      Tasks: 3 (limit: 2209)
     Memory: 12.7M (peak: 818.9M swap: 6.7M swap peak: 17.9M)
        CPU: 1h 12min 44.176s
     CGroup: /system.slice/nginx.service
             ├─ 2730 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─61629 "nginx: worker process"
             └─61630 "nginx: worker process"

Jul 21 15:36:05 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 21 15:42:52 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 21 15:42:52 ip-172-31-23-158 nginx[19390]: 2026/07/21 18:42:52 [notice] 19390#19390: signal process started
Jul 21 15:42:52 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 21 22:52:49 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 21 22:52:49 ip-172-31-23-158 nginx[33120]: 2026/07/22 01:52:49 [notice] 33120#33120: signal process started
Jul 21 22:52:49 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 23 16:17:29 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 23 16:17:29 ip-172-31-23-158 nginx[61437]: 2026/07/23 16:17:29 [notice] 61437#61437: signal process started
Jul 23 16:17:29 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
```

## Serviços das aplicações

### `conv-app-api.service`

| Propriedade | Valor |
|---|---|
| Ativo | `inactive` |
| Habilitado | `enabled` |

```text
○ conv-app-api.service - conv-app API FastAPI
     Loaded: loaded (/etc/systemd/system/conv-app-api.service; enabled; preset: enabled)
     Active: inactive (dead)
```

### `conv-app-web.service`

| Propriedade | Valor |
|---|---|
| Ativo | `inactive` |
| Habilitado | `enabled` |

```text
○ conv-app-web.service - conv-app Astro Web
     Loaded: loaded (/etc/systemd/system/conv-app-web.service; enabled; preset: enabled)
     Active: inactive (dead)
```

