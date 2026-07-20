ssh \
  -i /home/daniel/amazon.ssh \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=120 \
  -o TCPKeepAlive=yes \
  ubuntu@44.194.90.24