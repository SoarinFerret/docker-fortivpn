FROM ubuntu:16.04

RUN apt-get update && \
  apt-get install -y expect net-tools iproute ipppd iptables && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /root

# Copy & install fortissl client
COPY forticlientsslvpn_linux.tar.gz ./forticlientsslvpn_linux.tar.gz
RUN mkdir /usr/share/forticlient
RUN tar -xzf forticlientsslvpn_linux.tar.gz -C /usr/share/forticlient

# Run setup
RUN /usr/share/forticlient/forticlientsslvpn/64bit/helper/setup.linux.sh 2

# Copy runfiles
COPY fortissl /usr/bin/fortissl
COPY start.sh /start.sh

CMD [ "/start.sh" ]

# command to build container
# docker build -t linux-fortissl .