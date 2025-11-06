#!/bin/bash

#Note: This script needs to be executed with root privileges otherwise it will not work as intended. (Use sudo bash OpenvpnServer.sh)

set -e

CA_Name="UTS_SME"
CLIENT_Name="client1"


#This file will be used to log activity
logfile="/var/log/openvpnserverinstall.log"
#This is a shortcut variable to make and cd the easyrsa directory
easyrsa_dir=/etc/openvpn/easy-rsa

echo "Updating system packages..."
apt update && apt upgrade -y >> "$logfile" 2>&1

echo "Installing Openvpn and easyrsa..."
apt install -y openvpn easy-rsa >> "$logfile" 2>&1

echo "Setting up easyrsa environment..."
make-cadir "$easyrsa_dir"
cd "$easyrsa_dir"
chmod 700 "$easyrsa_dir"

echo "Initialising PKI..."
./easyrsa init-pki

echo "Building Certificate Authority..."
#The first part of the command is assigning the CA name to the command when it asks for it, in this case the CA
#name of UTS_SME will be assigned to the CA
printf "%s\n" "$CA_Name" | ./easyrsa build-ca nopass

echo "Generating Server Certificate and Key..."
printf "%s\n" "UTS_SME_OpenVPN_Server" | ./easyrsa gen-req UTS_SME_OpenVPN_Server nopass
printf "yes\n" | ./easyrsa sign-req server UTS_SME_OpenVPN_Server <<EOF
yes
EOF

echo "Generating Client Certificate and Key..."
printf "%s\n" "$CLIENT_Name" | ./easyrsa gen-req "$CLIENT_Name" nopass
printf "yes\n" | ./easyrsa sign-req client "$CLIENT_Name" <<EOF
yes
EOF

echo "Generating Diffie-Hellman Parameters and TLS Key..."
./easyrsa gen-dh
sudo openvpn --genkey --secret /etc/openvpn/ta.key

echo "Copying certificates and keys into Openvpn directory..."
cp pki/dh.pem pki/ca.crt pki/issued/UTS_SME_OpenVPN_Server.crt pki/private/UTS_SME_OpenVPN_Server.key /etc/openvpn/
mkdir -p /home/"$CLIENT_Name"
cp pki/ca.crt pki/issued/"$CLIENT_Name".crt pki/private/"$CLIENT_Name".key /etc/openvpn/ta.key /home/"$CLIENT_Name"

echo "Creating Openvpn Server Configuration..."
cat > /etc/openvpn/UTS_SME_Server.conf <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert UTS_SME_OpenVPN_Server.crt
key UTS_SME_OpenVPN_Server.key
dh dh.pem
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
keepalive 10 120
tls-auth ta.key 0
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
verb 3
explicit-exit-notify 1
EOF

echo "Enabling IP Forwarding..."
cat > /etc/sysctl.d/99-openvpn-ip-forwarding.conf <<EOF
net.ipv4.ip_forward=1
EOF
sysctl --system

echo "Setting UFW Rules..."
ufw allow 1194/udp
ufw --force enable

echo "Starting OpenVPN Server..."
sudo systemctl enable openvpn@UTS_SME_Server
sudo systemctl start openvpn@UTS_SME_Server

echo "Server Setup Complete."
