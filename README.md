# Docker-FortiVPN

This project is built off / inspired by the work provided here: [docker-forticlient](https://github.com/AuchanDirect/docker-forticlient)

Instead of messing with routes and such like the above, this just uses IPTables to perform port forwarding of mapped ports. For example, you only need RDP access to a specific server over the VPN. By default, this works with SSH, RDP, VNC, and WinRM; and it is easily modifiable for other ports / services as well.

## Environment Varibles

Here are a list of the required environment variables:

* `VPNADDR`: Url of the VPN with port. For example, `fortigate.example.com:8443`
* `VPNHASH`: Hash of the certificate used by the VPN
* `VPNUSER`: Username for the user connecting to the VPN
* `VPNPASS`: Password of the user connection to the VPN
* `HOSTIP`: IP of the host you want to connect to on the other side

## Usage / Examples

Make sure to run this container with `privileged` access. Otherwise you cannot use PPPD which the VPN relies on.

The below example shows how to run it with every port. After executing the below, you could use `mstsc 127.0.0.1:33389` or `ssh 127.0.0.1 -p 22222` or etc to reach your specified host.

```bash
docker run --restart=always --privileged -d -it \
    --name="VPNConnection" \
    -p 22222:22222 \
    -p 33389:33389 \
    -p 55900:55900 \
    -p 55985:55985 \
    -e VPNADDR="fortigate.example.com:8088" \
    -e VPNHASH=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    -e VPNUSER=admin \
    -e VPNPASS="password" \
    -e HOSTIP=172.20.1.30 \
    soarinferret/fortivpn
```

### Docker-Compose

A docker-compose.yml file is included for your convienence. I use a similar docker-compose file to stand up around 10 VPNs to different locations.

```bash
# Using docker-compose
# Make sure to edit the environment variables within the docker-compose file
docker-compose up
```

## Building

If you want to modify the container and update it with different functionality, follow the steps below:

```bash
# download
git clone https://github.com/SoarinFerret/linux-fortissl.git

# make your changes

# build
docker build -t fortivpn .
```