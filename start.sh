#!/bin/sh

if [ -z "$VPNADDR" -o -z "$VPNUSER" -o -z "$VPNPASS" -o -z "$HOSTIP" ]; then
  echo "Variables HOSTIP, VPNADDR, VPNUSER and VPNPASS must be set."; exit;
fi

if [ -z "$VPNHASH" ]; then
  echo "Variable VPNHASH is required";
  trustedcert=$(/usr/bin/openfortivpn ${VPNADDR} -u ${VPNUSER} -p ${VPNPASS}| grep trusted-cert | head -n 1 | awk -F "--" ' { print $2} ' | sed -e 's/trusted-cert//g')
  echo "Trusted cert for $VPNADDR is$trustedcert";
  exit;
fi

export VPNTIMEOUT=${VPNTIMEOUT:-5}

# Setup IPTABLES

## RDP
iptables -t nat -A PREROUTING -p tcp --dport 33389 -j DNAT --to-destination  ${HOSTIP}:3389 > /dev/null 2>&1

## ...and check for privileged access real quickly like
if ! [ $? -eq 0 ]; then
    echo "Sorry, this container requires the '--priviledged' flag to be set in order to use PPPD for VPN functionality"
    exit 1;
fi

## SSH
iptables -t nat -A PREROUTING -p tcp --dport 22222 -j DNAT --to-destination  ${HOSTIP}:22
## VNC / ARD
iptables -t nat -A PREROUTING -p tcp --dport 55900 -j DNAT --to-destination  ${HOSTIP}:5900
## WinRM
iptables -t nat -A PREROUTING -p tcp --dport 55985 -j DNAT --to-destination  ${HOSTIP}:5985
iptables -t nat -A POSTROUTING -j MASQUERADE

# Setup masquerade, to allow using the container as a gateway
for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
  iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
done

while [ true ]; do
  echo "------------ VPN Starts ------------"
  /usr/bin/openfortivpn ${VPNADDR} -u ${VPNUSER} -p ${VPNPASS} --trusted-cert ${VPNHASH}
  echo "------------ VPN exited ------------"
  sleep 10
done
