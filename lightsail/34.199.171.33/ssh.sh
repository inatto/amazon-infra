ssh \
  -i /home/daniel/amazon.ssh \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=120 \
  -o TCPKeepAlive=yes \
  bitnami@34.199.171.33