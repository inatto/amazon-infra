# Informações do servidor

> Gerado automaticamente. Os valores representam o momento da coleta.

| Item | Valor |
|---|---|
| Coletado em | `2026-07-21T18:48:59+00:00` |
| Hostname | `ip-172-31-23-158.sa-east-1.compute.internal` |
| Sistema | `Ubuntu 24.04.4 LTS` |
| Kernel | `6.17.0-1019-aws` |
| Arquitetura | `x86_64` |
| Uptime | `up 3 hours, 14 minutes` |
| Inicializado em | `2026-07-21 15:34:32` |
| Carga 1/5/15 min | `0.06 0.05 0.01` |
| CPUs lógicas | `2` |

## Memória e swap

```text
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       830Mi       367Mi       3.2Mi       917Mi       1.1Gi
Swap:             0B          0B          0B
```

## Disco

```text
Filesystem      Type      Size  Used Avail Use% Mounted on
/dev/root       ext4       29G  3.5G   25G  13% /
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
Total: 125
 18:48:59 up  3:14,  2 users,  load average: 0.06, 0.05, 0.01
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
tcp   LISTEN 0      2048            127.0.0.1:8002      0.0.0.0:*    users:(("python",pid=14412,fd=3),("python",pid=14411,fd=3),("uvicorn",pid=14359,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8001      0.0.0.0:*    users:(("python",pid=11018,fd=3),("python",pid=11017,fd=3),("uvicorn",pid=11012,fd=3))
tcp   LISTEN 0      4096              0.0.0.0:22        0.0.0.0:*                                                                                          
tcp   LISTEN 0      511             127.0.0.1:4002      0.0.0.0:*    users:(("node",pid=14417,fd=21))                                                      
tcp   LISTEN 0      511             127.0.0.1:4001      0.0.0.0:*    users:(("node",pid=11073,fd=21))                                                      
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
     Active: active (running) since Tue 2026-07-21 15:39:34 UTC; 3h 9min ago
       Docs: man:nginx(8)
   Main PID: 2730 (nginx)
      Tasks: 3 (limit: 2209)
     Memory: 6.3M (peak: 10.2M)
        CPU: 3.844s
     CGroup: /system.slice/nginx.service
             ├─ 2730 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─19552 "nginx: worker process"
             └─19553 "nginx: worker process"

Jul 21 18:16:01 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 21 18:30:03 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 21 18:30:03 ip-172-31-23-158 nginx[16352]: 2026/07/21 18:30:03 [notice] 16352#16352: signal process started
Jul 21 18:30:03 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 21 18:36:04 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 21 18:36:05 ip-172-31-23-158 nginx[17740]: 2026/07/21 18:36:05 [notice] 17740#17740: signal process started
Jul 21 18:36:05 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Jul 21 18:42:52 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Jul 21 18:42:52 ip-172-31-23-158 nginx[19390]: 2026/07/21 18:42:52 [notice] 19390#19390: signal process started
Jul 21 18:42:52 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
```

## Serviços das aplicações

### `orbital-api.service`

| Propriedade | Valor |
|---|---|
| Ativo | `active` |
| Habilitado | `enabled` |

```text
● orbital-api.service - orbital-app API FastAPI
     Loaded: loaded (/etc/systemd/system/orbital-api.service; enabled; preset: enabled)
     Active: active (running) since Tue 2026-07-21 16:55:22 UTC; 1h 53min ago
   Main PID: 11012 (uvicorn)
      Tasks: 11 (limit: 2209)
     Memory: 161.9M (peak: 161.9M)
        CPU: 36.601s
     CGroup: /system.slice/orbital-api.service
             ├─11012 /home/ubuntu/apps/orbital-app/apps/api/.venv/bin/python /home/ubuntu/apps/orbital-app/apps/api/.venv/bin/uvicorn main:app --host 127.0.0.1 --port 8001 --workers 2
             ├─11016 /home/ubuntu/apps/orbital-app/apps/api/.venv/bin/python -c "from multiprocessing.resource_tracker import main;main(6)"
             ├─11017 /home/ubuntu/apps/orbital-app/apps/api/.venv/bin/python -c "from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=7, pipe_handle=9)" --multiprocessing-fork
             └─11018 /home/ubuntu/apps/orbital-app/apps/api/.venv/bin/python -c "from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=7, pipe_handle=13)" --multiprocessing-fork

Jul 21 17:49:50 ip-172-31-23-158 uvicorn[11018]: INFO:     148.227.83.107:0 - "GET /members/page?tenant_code=anpprev&limit=1&offset=0&etype_code=admin&dashboard=true HTTP/1.1" 200 OK
Jul 21 17:49:50 ip-172-31-23-158 uvicorn[11017]: INFO:     148.227.83.107:0 - "GET /members/page?tenant_code=anpprev&limit=1&offset=0&etype_code=associate&dashboard=true HTTP/1.1" 200 OK
Jul 21 17:49:51 ip-172-31-23-158 uvicorn[11017]: INFO:     148.227.83.107:0 - "GET /members/page?tenant_code=anpprev&limit=1&offset=0&etype_code=financial&dashboard=true HTTP/1.1" 200 OK
Jul 21 17:49:51 ip-172-31-23-158 uvicorn[11018]: INFO:     148.227.83.107:0 - "GET /members/page?tenant_code=anpprev&limit=1&offset=0&etype_code=dependent&dashboard=true HTTP/1.1" 200 OK
Jul 21 17:49:51 ip-172-31-23-158 uvicorn[11018]: INFO:     148.227.83.107:0 - "GET /members/page?tenant_code=anpprev&limit=1&offset=0&etype_code=juridico&dashboard=true HTTP/1.1" 200 OK
Jul 21 18:04:21 ip-172-31-23-158 uvicorn[11018]: INFO:     148.227.83.107:0 - "GET /health HTTP/1.1" 200 OK
Jul 21 18:04:21 ip-172-31-23-158 uvicorn[11018]: INFO:     148.227.83.107:0 - "GET /health HTTP/1.1" 200 OK
Jul 21 18:43:11 ip-172-31-23-158 uvicorn[11017]: INFO:     201.48.202.229:0 - "GET /health HTTP/1.1" 200 OK
Jul 21 18:43:11 ip-172-31-23-158 uvicorn[11018]: INFO:     201.48.202.229:0 - "GET /me/menu HTTP/1.1" 200 OK
Jul 21 18:43:11 ip-172-31-23-158 uvicorn[11018]: INFO:     201.48.202.229:0 - "GET /votings/page?limit=20&offset=0 HTTP/1.1" 200 OK
```

### `orbital-web.service`

| Propriedade | Valor |
|---|---|
| Ativo | `active` |
| Habilitado | `enabled` |

```text
● orbital-web.service - orbital-app Astro Web
     Loaded: loaded (/etc/systemd/system/orbital-web.service; enabled; preset: enabled)
     Active: active (running) since Tue 2026-07-21 16:55:23 UTC; 1h 53min ago
   Main PID: 11073 (node)
      Tasks: 11 (limit: 2209)
     Memory: 30.0M (peak: 34.0M)
        CPU: 1.586s
     CGroup: /system.slice/orbital-web.service
             └─11073 /usr/bin/node /home/ubuntu/apps/orbital-app/apps/web/dist/server/entry.mjs

Jul 21 16:55:23 ip-172-31-23-158 systemd[1]: Started orbital-web.service - orbital-app Astro Web.
Jul 21 16:55:23 ip-172-31-23-158 node[11073]: 16:55:23 [@astrojs/node] Server listening on http://127.0.0.1:4001
```

