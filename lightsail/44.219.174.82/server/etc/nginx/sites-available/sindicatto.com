server {
    server_name sindicatto.com www.sindicatto.com;

    root /home/ubuntu/sindicatto/sites/sindicatto-web/dist;
    index index.html;

    client_max_body_size 20M;

    location / {
        try_files $uri $uri/ /index.html;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/sindicatto.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/sindicatto.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = www.sindicatto.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = sindicatto.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name sindicatto.com www.sindicatto.com;
    return 404; # managed by Certbot




}