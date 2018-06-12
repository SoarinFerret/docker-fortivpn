#!/bin/sh

if [ -z "$VPNADDR" -o -z "$VPNUSER" -o -z "$VPNPASS" -o -z "$VPNRDPIP" ]; then
  echo "Variables VPNRDPIP, VPNADDR, VPNUSER and VPNPASS must be set."; exit;
fi

export VPNTIMEOUT=${VPNTIMEOUT:-5}

# RDP
iptables -t nat -A PREROUTING -p tcp --dport 33389 -j DNAT --to-destination  ${VPNRDPIP}:3389
# SSH
iptables -t nat -A PREROUTING -p tcp --dport 22222 -j DNAT --to-destination  ${VPNRDPIP}:22
# VNC / ARD
iptables -t nat -A PREROUTING -p tcp --dport 55900 -j DNAT --to-destination  ${VPNRDPIP}:5900
# WinRM
iptables -t nat -A PREROUTING -p tcp --dport 55985 -j DNAT --to-destination  ${VPNRDPIP}:5985
iptables -t nat -A POSTROUTING -j MASQUERADE

# Setup masquerade, to allow using the container as a gateway
for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
  iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
done

while [ true ]; do
  echo "------------ VPN Starts ------------"
  /usr/bin/fortissl
  echo "------------ VPN exited ------------"
  sleep 10
done
