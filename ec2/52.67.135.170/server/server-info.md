# Informações do servidor

> Gerado automaticamente. Os valores representam o momento da coleta.

| Item | Valor |
|---|---|
| Coletado em | `2026-07-28T19:40:40-03:00` |
| Hostname | `ip-172-31-23-158.sa-east-1.compute.internal` |
| Sistema | `Ubuntu 24.04.4 LTS` |
| Kernel | `6.17.0-1019-aws` |
| Arquitetura | `x86_64` |
| Uptime | `up 1 week, 7 hours, 6 minutes` |
| Inicializado em | `2026-07-21 12:34:32` |
| Carga 1/5/15 min | `0.02 0.04 0.00` |
| CPUs lógicas | `2` |

## Memória e swap

```text
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       1.2Gi       111Mi       5.2Mi       750Mi       650Mi
Swap:          2.0Gi       647Mi       1.4Gi
```

## Disco

```text
Filesystem      Type      Size  Used Avail Use% Mounted on
/dev/root       ext4       29G   12G   17G  43% /
efivarfs        efivarfs  128K  3.3K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16 ext4      881M  163M  657M  20% /boot
/dev/nvme0n1p15 vfat      105M  6.2M   99M   6% /boot/efi
```

## Inodes

```text
Filesystem      Inodes IUsed IFree IUse% Mounted on
/dev/root         3.7M  317K  3.4M    9% /
efivarfs             0     0     0     - /sys/firmware/efi/efivars
/dev/nvme0n1p16    58K   605   57K    2% /boot
/dev/nvme0n1p15      0     0     0     - /boot/efi
```

## Processos

```text
Total: 147
 19:40:40 up 7 days,  7:06,  1 user,  load average: 0.02, 0.04, 0.00
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
tcp   LISTEN 0      2048            127.0.0.1:8003      0.0.0.0:*    users:(("python",pid=170168,fd=3),("python",pid=170167,fd=3),("uvicorn",pid=170162,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8002      0.0.0.0:*    users:(("python",pid=161331,fd=3),("python",pid=161330,fd=3),("uvicorn",pid=161291,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8001      0.0.0.0:*    users:(("python",pid=180820,fd=3),("python",pid=180819,fd=3),("uvicorn",pid=180814,fd=3))
tcp   LISTEN 0      4096              0.0.0.0:22        0.0.0.0:*                                                                                             
tcp   LISTEN 0      2048            127.0.0.1:8005      0.0.0.0:*    users:(("uvicorn",pid=161000,fd=13))                                                     
tcp   LISTEN 0      511             127.0.0.1:4003      0.0.0.0:*    users:(("node",pid=170502,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4002      0.0.0.0:*    users:(("node",pid=161292,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4001      0.0.0.0:*    users:(("node",pid=181287,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4005      0.0.0.0:*    users:(("node",pid=161003,fd=21))                                                        
tcp   LISTEN 0      2048            127.0.0.1:8100      0.0.0.0:*    users:(("python",pid=161276,fd=3),("python",pid=161271,fd=3),("uvicorn",pid=161257,fd=3))
tcp   LISTEN 0      511             127.0.0.1:4004      0.0.0.0:*    users:(("node",pid=160978,fd=21))                                                        
tcp   LISTEN 0      2048            127.0.0.1:8106      0.0.0.0:*    users:(("python",pid=174088,fd=3),("python",pid=174087,fd=3),("uvicorn",pid=174083,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8108      0.0.0.0:*    users:(("uvicorn",pid=161064,fd=13))                                                     
tcp   LISTEN 0      4096        127.0.0.53%lo:53        0.0.0.0:*                                                                                             
tcp   LISTEN 0      511               0.0.0.0:443       0.0.0.0:*                                                                                             
tcp   LISTEN 0      511             127.0.0.1:4100      0.0.0.0:*    users:(("node",pid=161258,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4106      0.0.0.0:*    users:(("node",pid=174497,fd=21))                                                        
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
     Active: active (running) since Tue 2026-07-28 06:55:24 -03; 12h ago
       Docs: man:nginx(8)
   Main PID: 161053 (nginx)
      Tasks: 3 (limit: 2209)
     Memory: 18.4M (peak: 524.7M swap: 3.8M swap peak: 6.1M)
        CPU: 9min 47.343s
     CGroup: /system.slice/nginx.service
             ├─161053 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─182156 "nginx: worker process"
             └─182157 "nginx: worker process"

Jul 28 06:55:24 ip-172-31-23-158 systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.
Jul 28 13:02:31 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 28 13:02:31 ip-172-31-23-158 nginx[164399]: 2026/07/28 13:02:31 [notice] 164399#164399: signal process started
Jul 28 13:02:31 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 28 14:53:30 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 28 14:53:30 ip-172-31-23-158 nginx[173126]: 2026/07/28 14:53:30 [notice] 173126#173126: signal process started
Jul 28 14:53:30 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 28 19:34:27 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 28 19:34:27 ip-172-31-23-158 nginx[181985]: 2026/07/28 19:34:27 [notice] 181985#181985: signal process started
Jul 28 19:34:27 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
```

## Serviços das aplicações

### `orbital-content-api.service`

| Propriedade | Valor |
|---|---|
| Ativo | `inactive` |
| Habilitado | `enabled` |

```text
○ orbital-content-api.service - orbital-content API FastAPI
     Loaded: loaded (/etc/systemd/system/orbital-content-api.service; enabled; preset: enabled)
     Active: inactive (dead)
```

### `orbital-content-web.service`

| Propriedade | Valor |
|---|---|
| Ativo | `inactive` |
| Habilitado | `enabled` |

```text
○ orbital-content-web.service - orbital-content Astro Web
     Loaded: loaded (/etc/systemd/system/orbital-content-web.service; enabled; preset: enabled)
     Active: inactive (dead)
```

