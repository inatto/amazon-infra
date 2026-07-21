ssh \
  -i /home/daniel/Code/infra/amazon-infra/ec2/52.67.135.170/core/inatto01-sp.pem \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=120 \
  -o TCPKeepAlive=yes \
  ubuntu@52.67.135.170