# Informações do servidor

> Gerado automaticamente. Os valores representam o momento da coleta.

| Item | Valor |
|---|---|
| Coletado em | `2026-08-11T17:04:28-03:00` |
| Hostname | `ip-172-31-23-158.sa-east-1.compute.internal` |
| Sistema | `Ubuntu 24.04.4 LTS` |
| Kernel | `6.17.0-1019-aws` |
| Arquitetura | `x86_64` |
| Uptime | `up 3 weeks, 4 hours, 29 minutes` |
| Inicializado em | `2026-07-21 12:34:32` |
| Carga 1/5/15 min | `0.12 0.07 0.05` |
| CPUs lógicas | `2` |

## Memória e swap

```text
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       1.2Gi       262Mi       2.5Mi       656Mi       690Mi
Swap:          2.0Gi       896Mi       1.1Gi
```

## Disco

```text
Filesystem      Type      Size  Used Avail Use% Mounted on
/dev/root       ext4       29G   16G   13G  55% /
efivarfs        efivarfs  128K  3.3K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16 ext4      881M  183M  637M  23% /boot
/dev/nvme0n1p15 vfat      105M  6.2M   99M   6% /boot/efi
```

## Inodes

```text
Filesystem      Inodes IUsed IFree IUse% Mounted on
/dev/root         3.7M  462K  3.2M   13% /
efivarfs             0     0     0     - /sys/firmware/efi/efivars
/dev/nvme0n1p16    58K   605   57K    2% /boot
/dev/nvme0n1p15      0     0     0     - /boot/efi
```

## Processos

```text
Total: 158
 17:04:28 up 21 days,  4:29,  1 user,  load average: 0.12, 0.07, 0.05
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
tcp   LISTEN 0      2048            127.0.0.1:8002      0.0.0.0:*    users:(("python",pid=439355,fd=3),("python",pid=218597,fd=3),("uvicorn",pid=218565,fd=3))  
tcp   LISTEN 0      2048            127.0.0.1:8001      0.0.0.0:*    users:(("python3",pid=452248,fd=3),("python3",pid=452247,fd=3),("uvicorn",pid=452238,fd=3))
tcp   LISTEN 0      4096              0.0.0.0:22        0.0.0.0:*                                                                                               
tcp   LISTEN 0      2048            127.0.0.1:8005      0.0.0.0:*    users:(("uvicorn",pid=218395,fd=13))                                                       
tcp   LISTEN 0      2048            127.0.0.1:8004      0.0.0.0:*    users:(("python3",pid=439250,fd=3),("python3",pid=427700,fd=3),("uvicorn",pid=427694,fd=3))
tcp   LISTEN 0      5               127.0.0.1:8113      0.0.0.0:*    users:(("python3",pid=438633,fd=3))                                                        
tcp   LISTEN 0      511             127.0.0.1:4002      0.0.0.0:*    users:(("node",pid=161292,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4001      0.0.0.0:*    users:(("node",pid=452802,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4005      0.0.0.0:*    users:(("node",pid=161003,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4004      0.0.0.0:*    users:(("node",pid=427973,fd=21))                                                          
tcp   LISTEN 0      2048            127.0.0.1:8100      0.0.0.0:*    users:(("python",pid=439227,fd=3),("python",pid=438412,fd=3),("uvicorn",pid=218521,fd=3))  
tcp   LISTEN 0      2048            127.0.0.1:8106      0.0.0.0:*    users:(("python3",pid=451823,fd=3),("python3",pid=451822,fd=3),("uvicorn",pid=451814,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8104      0.0.0.0:*    users:(("python3",pid=460452,fd=3),("python3",pid=460451,fd=3),("uvicorn",pid=460446,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8111      0.0.0.0:*    users:(("python3",pid=439195,fd=3),("python3",pid=435980,fd=3),("uvicorn",pid=434121,fd=3))
tcp   LISTEN 0      4096        127.0.0.53%lo:53        0.0.0.0:*                                                                                               
tcp   LISTEN 0      511               0.0.0.0:443       0.0.0.0:*                                                                                               
tcp   LISTEN 0      5               127.0.0.1:4113      0.0.0.0:*    users:(("python3",pid=431853,fd=3))                                                        
tcp   LISTEN 0      511             127.0.0.1:4101      0.0.0.0:*    users:(("node",pid=421496,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4100      0.0.0.0:*    users:(("node",pid=161258,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4106      0.0.0.0:*    users:(("node",pid=452569,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4104      0.0.0.0:*    users:(("node",pid=460731,fd=21))                                                          
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
     Active: active (running) since Tue 2026-08-11 06:59:18 -03; 10h ago
       Docs: man:nginx(8)
    Process: 461081 ExecReload=/usr/sbin/nginx -g daemon on; master_process on; -s reload (code=exited, status=0/SUCCESS)
   Main PID: 458096 (nginx)
      Tasks: 3 (limit: 2209)
     Memory: 9.3M (peak: 14.6M)
        CPU: 1.597s
     CGroup: /system.slice/nginx.service
             ├─458096 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─461252 "nginx: worker process"
             └─461253 "nginx: worker process"

Aug 11 06:59:18 ip-172-31-23-158 systemd[1]: Starting nginx.service - A high performance web server and a reverse proxy server...
Aug 11 06:59:18 ip-172-31-23-158 systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.
Aug 11 17:03:57 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Aug 11 17:03:57 ip-172-31-23-158 nginx[461081]: 2026/08/11 17:03:57 [notice] 461081#461081: signal process started
Aug 11 17:03:57 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
```

