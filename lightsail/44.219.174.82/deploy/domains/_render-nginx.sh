#!/usr/bin/env bash
# cd /home/daniel/Code/sind-infra/sind-amazon/lightsail/44.219.174.82/deploy/domains

render_nginx() {
  local output_file="$1"
  local certificate_name="$PRIMARY_DOMAIN"
  local ssl_enabled="false"

  if remote "sudo test -s '/etc/letsencrypt/live/$certificate_name/fullchain.pem' && sudo test -s '/etc/letsencrypt/live/$certificate_name/privkey.pem'"; then
    ssl_enabled="true"
  fi

  if [[ "$ssl_enabled" == "true" ]]; then
    cat > "$output_file" <<NGINX
server {
    listen 80;
    listen [::]:80;

    server_name $DOMAIN_LIST;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name $DOMAIN_LIST;

    ssl_certificate /etc/letsencrypt/live/$certificate_name/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$certificate_name/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    add_header X-Site-App "$APP_NAME" always;
    client_max_body_size ${CLIENT_MAX_BODY_SIZE:-20m};
NGINX
  else
    cat > "$output_file" <<NGINX
server {
    listen 80;
    listen [::]:80;

    server_name $DOMAIN_LIST;

    add_header X-Site-App "$APP_NAME" always;
    client_max_body_size ${CLIENT_MAX_BODY_SIZE:-20m};
NGINX
  fi

  if [[ -n "${API_UPSTREAM_PORT:-}" ]]; then
    cat >> "$output_file" <<NGINX

    location = /api {
        return 308 /api/;
    }

    location /api/ {
        proxy_pass http://${API_UPSTREAM_HOST:-$WEB_UPSTREAM_HOST}:$API_UPSTREAM_PORT/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout ${API_PROXY_READ_TIMEOUT:-120s};
        proxy_connect_timeout ${API_PROXY_CONNECT_TIMEOUT:-30s};
        proxy_send_timeout ${API_PROXY_SEND_TIMEOUT:-120s};
    }
NGINX
  fi

  cat >> "$output_file" <<NGINX

    location / {
        proxy_pass http://$WEB_UPSTREAM_HOST:$WEB_UPSTREAM_PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout ${WEB_PROXY_READ_TIMEOUT:-60s};
    }
}
NGINX
}
