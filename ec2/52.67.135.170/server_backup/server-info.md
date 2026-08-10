# Informações do servidor

> Gerado automaticamente. Os valores representam o momento da coleta.

| Item | Valor |
|---|---|
| Coletado em | `2026-08-09T20:55:24-03:00` |
| Hostname | `ip-172-31-23-158.sa-east-1.compute.internal` |
| Sistema | `Ubuntu 24.04.4 LTS` |
| Kernel | `6.17.0-1019-aws` |
| Arquitetura | `x86_64` |
| Uptime | `up 2 weeks, 5 days, 8 hours, 20 minutes` |
| Inicializado em | `2026-07-21 12:34:32` |
| Carga 1/5/15 min | `1.26 1.14 0.74` |
| CPUs lógicas | `2` |

## Memória e swap

```text
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       1.1Gi       205Mi       3.1Mi       829Mi       825Mi
Swap:          2.0Gi       837Mi       1.2Gi
```

## Disco

```text
Filesystem      Type      Size  Used Avail Use% Mounted on
/dev/root       ext4       29G   15G   14G  52% /
efivarfs        efivarfs  128K  3.3K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16 ext4      881M  183M  637M  23% /boot
/dev/nvme0n1p15 vfat      105M  6.2M   99M   6% /boot/efi
```

## Inodes

```text
Filesystem      Inodes IUsed IFree IUse% Mounted on
/dev/root         3.7M  384K  3.3M   11% /
efivarfs             0     0     0     - /sys/firmware/efi/efivars
/dev/nvme0n1p16    58K   605   57K    2% /boot
/dev/nvme0n1p15      0     0     0     - /boot/efi
```

## Processos

```text
Total: 155
 20:55:24 up 19 days,  8:20,  1 user,  load average: 1.26, 1.14, 0.74
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
tcp   LISTEN 0      4096              0.0.0.0:22        0.0.0.0:*                                                                                             
tcp   LISTEN 0      2048            127.0.0.1:8005      0.0.0.0:*    users:(("uvicorn",pid=218395,fd=13))                                                     
tcp   LISTEN 0      2048            127.0.0.1:8004      0.0.0.0:*    users:(("python",pid=274194,fd=13))                                                      
tcp   LISTEN 0      511             127.0.0.1:4003      0.0.0.0:*    users:(("node",pid=170502,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4002      0.0.0.0:*    users:(("node",pid=161292,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4001      0.0.0.0:*    users:(("node",pid=272038,fd=21))                                                        
tcp   LISTEN 0      2048            127.0.0.1:8102      0.0.0.0:*    users:(("python",pid=218539,fd=3),("python",pid=218538,fd=3),("uvicorn",pid=218526,fd=3))
tcp   LISTEN 0      511             127.0.0.1:4005      0.0.0.0:*    users:(("node",pid=161003,fd=21))                                                        
tcp   LISTEN 0      511             127.0.0.1:4004      0.0.0.0:*    users:(("node",pid=274383,fd=21))                                                        
tcp   LISTEN 0      2048            127.0.0.1:8100      0.0.0.0:*    users:(("python",pid=218531,fd=3),("python",pid=218530,fd=3),("uvicorn",pid=218521,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8106      0.0.0.0:*    users:(("python",pid=223603,fd=3),("python",pid=223602,fd=3),("uvicorn",pid=223598,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8108      0.0.0.0:*    users:(("uvicorn",pid=278869,fd=13))                                                     
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
     Active: active (running) since Fri 2026-07-31 06:23:54 -03; 1 week 2 days ago
       Docs: man:nginx(8)
    Process: 282421 ExecReload=/usr/sbin/nginx -g daemon on; master_process on; -s reload (code=exited, status=0/SUCCESS)
   Main PID: 218401 (nginx)
      Tasks: 3 (limit: 2209)
     Memory: 9.5M (peak: 30.9M swap: 524.0K swap peak: 2.9M)
        CPU: 30.263s
     CGroup: /system.slice/nginx.service
             ├─218401 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─282423 "nginx: worker process"
             └─282424 "nginx: worker process"

Aug 09 18:56:36 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Aug 09 19:15:34 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Aug 09 19:15:34 ip-172-31-23-158 nginx[279433]: 2026/08/09 19:15:34 [notice] 279433#279433: signal process started
Aug 09 19:15:34 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Aug 09 19:16:00 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Aug 09 19:16:00 ip-172-31-23-158 nginx[279804]: 2026/08/09 19:16:00 [notice] 279804#279804: signal process started
Aug 09 19:16:00 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
Aug 09 20:53:21 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Aug 09 20:53:21 ip-172-31-23-158 nginx[282421]: 2026/08/09 20:53:21 [notice] 282421#282421: signal process started
Aug 09 20:53:21 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
```

