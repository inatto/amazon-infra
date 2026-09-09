ssh \
  -i /home/daniel/Code/infra/amazon-infra/.config/amazon.ssh \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=120 \
  -o TCPKeepAlive=yes \
  bitnami@34.231.5.155