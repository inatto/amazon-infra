# Informações do servidor

> Gerado automaticamente. Os valores representam o momento da coleta.

| Item | Valor |
|---|---|
| Coletado em | `2026-08-24T15:50:40-03:00` |
| Hostname | `ip-172-31-23-158.sa-east-1.compute.internal` |
| Sistema | `Ubuntu 24.04.4 LTS` |
| Kernel | `6.17.0-1019-aws` |
| Arquitetura | `x86_64` |
| Uptime | `up 4 weeks, 6 days, 3 hours, 16 minutes` |
| Inicializado em | `2026-07-21 12:34:32` |
| Carga 1/5/15 min | `0.15 0.14 0.13` |
| CPUs lógicas | `2` |

## Memória e swap

```text
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       1.3Gi       216Mi       3.7Mi       617Mi       622Mi
Swap:          2.0Gi       1.6Gi       441Mi
```

## Disco

```text
Filesystem      Type      Size  Used Avail Use% Mounted on
/dev/root       ext4       29G   16G   13G  56% /
efivarfs        efivarfs  128K  3.3K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16 ext4      881M  183M  637M  23% /boot
/dev/nvme0n1p15 vfat      105M  6.2M   99M   6% /boot/efi
```

## Inodes

```text
Filesystem      Inodes IUsed IFree IUse% Mounted on
/dev/root         3.7M  526K  3.2M   15% /
efivarfs             0     0     0     - /sys/firmware/efi/efivars
/dev/nvme0n1p16    58K   605   57K    2% /boot
/dev/nvme0n1p15      0     0     0     - /boot/efi
```

## Processos

```text
Total: 184
 15:50:40 up 34 days,  3:16,  1 user,  load average: 0.15, 0.14, 0.13
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
tcp   LISTEN 0      2048            127.0.0.1:8003      0.0.0.0:*    users:(("uvicorn",pid=786002,fd=13))                                                       
tcp   LISTEN 0      2048            127.0.0.1:8002      0.0.0.0:*    users:(("python3",pid=716488,fd=3),("python3",pid=716487,fd=3),("uvicorn",pid=716482,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8001      0.0.0.0:*    users:(("python",pid=765186,fd=3),("python",pid=765185,fd=3),("uvicorn",pid=765180,fd=3))  
tcp   LISTEN 0      4096              0.0.0.0:22        0.0.0.0:*                                                                                               
tcp   LISTEN 0      2048            127.0.0.1:8005      0.0.0.0:*    users:(("uvicorn",pid=514793,fd=13))                                                       
tcp   LISTEN 0      2048            127.0.0.1:8004      0.0.0.0:*    users:(("python",pid=787299,fd=3),("python",pid=787298,fd=3),("uvicorn",pid=787293,fd=3))  
tcp   LISTEN 0      5               127.0.0.1:8113      0.0.0.0:*    users:(("python3",pid=438633,fd=3))                                                        
tcp   LISTEN 0      2048            127.0.0.1:8112      0.0.0.0:*    users:(("python3",pid=572559,fd=3),("python3",pid=572558,fd=3),("uvicorn",pid=572522,fd=3))
tcp   LISTEN 0      511             127.0.0.1:4003      0.0.0.0:*    users:(("node",pid=786737,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4002      0.0.0.0:*    users:(("node",pid=716787,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4001      0.0.0.0:*    users:(("node",pid=765742,fd=21))                                                          
tcp   LISTEN 0      2048            127.0.0.1:8102      0.0.0.0:*    users:(("python",pid=788007,fd=3),("python",pid=788006,fd=3),("uvicorn",pid=788001,fd=3))  
tcp   LISTEN 0      2048            127.0.0.1:8101      0.0.0.0:*    users:(("python3",pid=770056,fd=3),("python3",pid=770055,fd=3),("uvicorn",pid=770050,fd=3))
tcp   LISTEN 0      511             127.0.0.1:4005      0.0.0.0:*    users:(("node",pid=515091,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4004      0.0.0.0:*    users:(("node",pid=787584,fd=21))                                                          
tcp   LISTEN 0      2048            127.0.0.1:8100      0.0.0.0:*    users:(("python",pid=439227,fd=3),("python",pid=438412,fd=3),("uvicorn",pid=218521,fd=3))  
tcp   LISTEN 0      2048            127.0.0.1:8106      0.0.0.0:*    users:(("python",pid=788811,fd=3),("python",pid=788810,fd=3),("uvicorn",pid=788801,fd=3))  
tcp   LISTEN 0      2048            127.0.0.1:8105      0.0.0.0:*    users:(("python3",pid=738929,fd=3),("python3",pid=738928,fd=3),("uvicorn",pid=738923,fd=3))
tcp   LISTEN 0      2048            127.0.0.1:8104      0.0.0.0:*    users:(("python",pid=738697,fd=3),("python",pid=738696,fd=3),("uvicorn",pid=738691,fd=3))  
tcp   LISTEN 0      2048            127.0.0.1:8111      0.0.0.0:*    users:(("python",pid=736413,fd=3),("python",pid=736412,fd=3),("uvicorn",pid=736407,fd=3))  
tcp   LISTEN 0      2048            127.0.0.1:8108      0.0.0.0:*    users:(("python",pid=740510,fd=3),("python",pid=740509,fd=3),("uvicorn",pid=740449,fd=3))  
tcp   LISTEN 0      4096        127.0.0.53%lo:53        0.0.0.0:*                                                                                               
tcp   LISTEN 0      511               0.0.0.0:443       0.0.0.0:*                                                                                               
tcp   LISTEN 0      5               127.0.0.1:4113      0.0.0.0:*    users:(("python3",pid=431853,fd=3))                                                        
tcp   LISTEN 0      511             127.0.0.1:4112      0.0.0.0:*    users:(("node",pid=573047,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4102      0.0.0.0:*    users:(("node",pid=788299,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4101      0.0.0.0:*    users:(("node",pid=770334,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4100      0.0.0.0:*    users:(("node",pid=161258,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4106      0.0.0.0:*    users:(("node",pid=789198,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4111      0.0.0.0:*    users:(("node",pid=736709,fd=21))                                                          
tcp   LISTEN 0      511             127.0.0.1:4108      0.0.0.0:*    users:(("node",pid=740834,fd=21))                                                          
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
     Active: active (running) since Fri 2026-08-21 06:13:26 -03; 3 days ago
       Docs: man:nginx(8)
    Process: 789781 ExecReload=/usr/sbin/nginx -g daemon on; master_process on; -s reload (code=exited, status=0/SUCCESS)
   Main PID: 728709 (nginx)
      Tasks: 3 (limit: 2209)
     Memory: 10.9M (peak: 31.9M swap: 296.0K swap peak: 2.8M)
        CPU: 20.266s
     CGroup: /system.slice/nginx.service
             ├─728709 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─789946 "nginx: worker process"
             └─789947 "nginx: worker process"

Aug 21 06:13:26 ip-172-31-23-158 systemd[1]: Starting nginx.service - A high performance web server and a reverse proxy server...
Aug 21 06:13:26 ip-172-31-23-158 systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.
Aug 24 15:50:06 ip-172-31-23-158 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Aug 24 15:50:06 ip-172-31-23-158 nginx[789781]: 2026/08/24 15:50:06 [notice] 789781#789781: signal process started
Aug 24 15:50:06 ip-172-31-23-158 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
```

