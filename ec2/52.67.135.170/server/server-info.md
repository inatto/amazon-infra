# Informações do servidor

> Gerado automaticamente. Os valores representam o momento da coleta.

| Item | Valor |
|---|---|
| Coletado em | `2026-08-04T20:17:16-03:00` |
| Hostname | `ip-172-31-23-158.sa-east-1.compute.internal` |
| Sistema | `Ubuntu 24.04.4 LTS` |
| Kernel | `6.17.0-1019-aws` |
| Arquitetura | `x86_64` |
| Uptime | `up 2 weeks, 7 hours, 42 minutes` |
| Inicializado em | `2026-07-21 12:34:32` |
| Carga 1/5/15 min | `0.13 0.07 0.01` |
| CPUs lógicas | `2` |

## Memória e swap

```text
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       1.1Gi        96Mi       2.9Mi       875Mi       763Mi
Swap:          2.0Gi       959Mi       1.1Gi
```

## Disco

```text
Filesystem      Type      Size  Used Avail Use% Mounted on
/dev/root       ext4       29G   14G   15G  50% /
efivarfs        efivarfs  128K  3.3K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16 ext4      881M  183M  637M  23% /boot
/dev/nvme0n1p15 vfat      105M  6.2M   99M   6% /boot/efi
```

## Inodes

```text
Filesystem      Inodes IUsed IFree IUse% Mounted on
/dev/root         3.7M  344K  3.3M   10% /
efivarfs             0     0     0     - /sys/firmware/efi/efivars
/dev/nvme0n1p16    58K   605   57K    2% /boot
/dev/nvme0n1p15      0     0     0     - /boot/efi
```

## Processos

```text
Total: 153
 20:17:16 up 14 days,  7:42,  1 user,  load average: 0.13, 0.07, 0.01
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
tcp   LISTEN 0      2048            127.0.0.1:8003      0.0.0.0:*    users:(("python",pid=218542,fd=3),("python",pid=218541,fd=3),("uvicorn",pid=218528,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8002      0.0.0.0:*    users:(("python",pid=218597,fd=3),("python",pid=218596,fd=3),("uvicorn",pid=218565,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8001      0.0.0.0:*    users:(("python",pid=218534,fd=3),("python",pid=218533,fd=3),("uvicorn",pid=218524,fd=3))
tcp   LISTEN 0      4096              0.0.0.0:22        0.0.0.0:*                                                                                             
tcp   LISTEN 0      2048            127.0.0.1:8005      0.0.0.0:*    users:(("uvicorn",pid=218395,fd=13))                                                     
tcp   LISTEN 0      511             127.0.0.1:4003      0.0.0.0:*    users:(("node",pid=170502,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4002      0.0.0.0:*    users:(("node",pid=161292,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4001      0.0.0.0:*    users:(("node",pid=181287,fd=21))                                                        
tcp   LISTEN 0      2048            127.0.0.1:8102      0.0.0.0:*    users:(("python",pid=218539,fd=3),("python",pid=218538,fd=3),("uvicorn",pid=218526,fd=3))
tcp   LISTEN 0      511             127.0.0.1:4005      0.0.0.0:*    users:(("node",pid=161003,fd=21))                                                        
tcp   LISTEN 0      2048            127.0.0.1:8100      0.0.0.0:*    users:(("python",pid=218531,fd=3),("python",pid=218530,fd=3),("uvicorn",pid=218521,fd=3))
tcp   LISTEN 0      511             127.0.0.1:4004      0.0.0.0:*    users:(("node",pid=160978,fd=21))                                                        
tcp   LISTEN 0      2048            127.0.0.1:8106      0.0.0.0:*    users:(("python",pid=223603,fd=3),("python",pid=223602,fd=3),("uvicorn",pid=223598,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8108      0.0.0.0:*    users:(("uvicorn",pid=218494,fd=13))                                                     
tcp   LISTEN 0      4096        127.0.0.53%lo:53        0.0.0.0:*                                                                                             
tcp   LISTEN 0      511               0.0.0.0:443       0.0.0.0:*                                                                                             
tcp   LISTEN 0      511             127.0.0.1:4102      0.0.0.0:*    users:(("node",pid=191749,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4100      0.0.0.0:*    users:(("node",pid=161258,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4106      0.0.0.0:*    users:(("node",pid=223999,fd=21))                                                        
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
     Active: active (running) since Fri 2026-07-31 06:23:54 -03; 4 days ago
       Docs: man:nginx(8)
   Main PID: 218401 (nginx)
      Tasks: 3 (limit: 2209)
     Memory: 10.7M (peak: 30.9M swap: 404.0K swap peak: 1.8M)
        CPU: 13.846s
     CGroup: /system.slice/nginx.service
             ├─218401 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─245090 "nginx: worker process"
             └─245091 "nginx: worker process"

Aug 04 14:19:21 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Aug 04 14:19:21 ip-172-31-23-158 nginx[240907]: 2026/08/04 14:19:21 [notice] 240907#240907: signal process started
Aug 04 14:19:21 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Aug 04 14:19:55 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Aug 04 14:19:55 ip-172-31-23-158 nginx[241396]: 2026/08/04 14:19:55 [notice] 241396#241396: signal process started
Aug 04 14:19:55 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Aug 04 20:16:16 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Aug 04 20:16:16 ip-172-31-23-158 nginx[244919]: 2026/08/04 20:16:16 [notice] 244919#244919: signal process started
Aug 04 20:16:16 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
```

## Serviços das aplicações

### `orbital-app-api.service`

| Propriedade | Valor |
|---|---|
| Ativo | `active` |
| Habilitado | `enabled` |

```text
● orbital-app-api.service - orbital-app API FastAPI
     Loaded: loaded (/etc/systemd/system/orbital-app-api.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-07-31 06:24:06 -03; 4 days ago
   Main PID: 218524 (uvicorn)
      Tasks: 10 (limit: 2209)
     Memory: 99.8M (peak: 155.9M swap: 126.5M swap peak: 128.4M)
        CPU: 31min 57.896s
     CGroup: /system.slice/orbital-app-api.service
             ├─218524 /home/ubuntu/apps/orbital/orbital-app/apps/api/.venv/bin/python /home/ubuntu/apps/orbital/orbital-app/apps/api/.venv/bin/uvicorn main:app --host 127.0.0.1 --port 8001 --workers 2
             ├─218532 /home/ubuntu/apps/orbital/orbital-app/apps/api/.venv/bin/python -c "from multiprocessing.resource_tracker import main;main(6)"
             ├─218533 /home/ubuntu/apps/orbital/orbital-app/apps/api/.venv/bin/python -c "from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=7, pipe_handle=9)" --multiprocessing-fork
             └─218534 /home/ubuntu/apps/orbital/orbital-app/apps/api/.venv/bin/python -c "from multiprocessing.spawn import spawn_main; spawn_main(tracker_fd=7, pipe_handle=13)" --multiprocessing-fork

Aug 04 18:54:27 ip-172-31-23-158 uvicorn[218533]: INFO:     127.0.0.1:36788 - "GET /api/health HTTP/1.1" 200 OK
Aug 04 18:55:27 ip-172-31-23-158 uvicorn[218533]: INFO:     127.0.0.1:46950 - "GET /api/health HTTP/1.1" 200 OK
Aug 04 18:56:27 ip-172-31-23-158 uvicorn[218533]: INFO:     127.0.0.1:46578 - "GET /api/health HTTP/1.1" 200 OK
Aug 04 18:57:27 ip-172-31-23-158 uvicorn[218534]: INFO:     127.0.0.1:35958 - "GET /api/health HTTP/1.1" 200 OK
Aug 04 18:58:27 ip-172-31-23-158 uvicorn[218534]: INFO:     127.0.0.1:55454 - "GET /api/health HTTP/1.1" 200 OK
Aug 04 18:59:27 ip-172-31-23-158 uvicorn[218534]: INFO:     127.0.0.1:45350 - "GET /api/health HTTP/1.1" 200 OK
Aug 04 19:00:28 ip-172-31-23-158 uvicorn[218533]: INFO:     127.0.0.1:54102 - "GET /api/health HTTP/1.1" 200 OK
Aug 04 19:01:27 ip-172-31-23-158 uvicorn[218534]: INFO:     127.0.0.1:43254 - "GET /api/health HTTP/1.1" 200 OK
Aug 04 19:02:04 ip-172-31-23-158 uvicorn[218534]: INFO:     127.0.0.1:39052 - "GET /api/health HTTP/1.1" 200 OK
Aug 04 19:48:10 ip-172-31-23-158 uvicorn[218534]: INFO:     5.101.64.6:0 - "GET /health/db HTTP/1.1" 404 Not Found
```

### `orbital-app-note-worker.service`

| Propriedade | Valor |
|---|---|
| Ativo | `active` |
| Habilitado | `enabled` |

```text
● orbital-app-note-worker.service - orbital-app Note Worker
     Loaded: loaded (/etc/systemd/system/orbital-app-note-worker.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-07-31 06:24:10 -03; 4 days ago
   Main PID: 218564 (python)
      Tasks: 1 (limit: 2209)
     Memory: 18.6M (peak: 64.7M swap: 38.9M swap peak: 38.9M)
        CPU: 3min 51.945s
     CGroup: /system.slice/orbital-app-note-worker.service
             └─218564 /home/ubuntu/apps/orbital/orbital-app/apps/api/.venv/bin/python -m workers.note_send_worker

Jul 31 06:24:10 ip-172-31-23-158 systemd[1]: Started orbital-app-note-worker.service - orbital-app Note Worker.
Jul 31 06:24:15 ip-172-31-23-158 bash[218564]: 2026-07-31 06:24:15,270 INFO Worker de notas iniciado: batch=100 poll=5.0s stale=900s recovery=60.0s pool=1+0
```

### `orbital-app-web.service`

| Propriedade | Valor |
|---|---|
| Ativo | `active` |
| Habilitado | `enabled` |

```text
● orbital-app-web.service - orbital-app Astro Web
     Loaded: loaded (/etc/systemd/system/orbital-app-web.service; enabled; preset: enabled)
     Active: active (running) since Tue 2026-07-28 18:47:20 -03; 1 week 0 days ago
   Main PID: 181287 (node)
      Tasks: 11 (limit: 2209)
     Memory: 38.8M (peak: 40.4M swap: 20.0M swap peak: 22.0M)
        CPU: 12.984s
     CGroup: /system.slice/orbital-app-web.service
             └─181287 /usr/bin/node /home/ubuntu/apps/orbital/orbital-app/apps/web/dist/server/entry.mjs

Jul 28 18:47:20 ip-172-31-23-158 systemd[1]: Started orbital-app-web.service - orbital-app Astro Web.
Jul 28 18:47:20 ip-172-31-23-158 node[181287]: 18:47:20 [@astrojs/node] Server listening on http://127.0.0.1:4001
```

