# Linux-FortiSSL
This project is built off of the work provided here: [docker-forticlient](https://github.com/AuchanDirect/docker-forticlient)

Instead of messing with routes and such like the above, this just uses IPTables to perform port forwarding of mapped ports. For example, you only need RDP access to a specific server over the VPN. By default, this works with SSH, RDP, VNC, and WinRM; and it is easily modifiable for other ports / services as well.

This is tested to be working on Linux and Windows, not sure about macOS.

## Prerequisites
Go to support.fortinet.com and download the forticlientsslvpn client and place it in the linux-fortissl folder. Rename it to `forticlientsslvpn_linux.tar.gz`. I cannot include that package here.

## Usage / Examples

A docker-compose.yml file is included for your convienence. I use a docker-compose file to stand up around 10 VPNs to different locations.

```
# Using docker-compose
# Make sure to edit the environment variables within the docker-compose file
docker-compose up

# Building and running the container manually
cd linux-fortissl
docker build -t linux-fortissl .
docker run --restart=always --privileged -d -it \
    --name="VPNConnection" \
    -p 22222:22222 \
    -p 33389:33389 \
    -p 55900:55900 \
    -p 55985:55985 \
    -e VPNADDR="fortigate.example.com:8088" \
    -e VPNUSER=admin \
    -e VPNPASS="password" \
    -e VPNRDPIP=172.20.1.30 \
    linux-fortissl
```