#!/bin/bash

#Note: This script needs to be executed with root privileges otherwise it will not work as intended. (Use sudo bash OpenvpnServer.sh)

set -e

SERVER_IP="192.168.30.2"
CLIENT_Name="client1"
USER="admin"

#This file will be used to log activity
logfile="/var/log/openvpnserverinstall.log"

echo "Updating system packages..."
apt update && apt upgrade -y >> "$logfile" 2>&1

echo "Installing Openvpn..."
apt install -y openvpn >> "$logfile" 2>&1

echo "Creating Client Directory..."
mkdir -p /etc/openvpn/client
cd /etc/openvpn

echo "Copying Certificates and Keys..."
cp /home/$USER/OpenVPN/"$CLIENT_Name"/ca.crt .
cp /home/$USER/OpenVPN/"$CLIENT_Name"/ta.key .
cp /home/$USER/OpenVPN/"$CLIENT_Name"/"$CLIENT_Name".key .
cp /home/$USER/OpenVPN/"$CLIENT_Name"/"$CLIENT_Name".crt .

echo "Creating OpenVPN Client Configuration..."
cat > /etc/openvpn/UTS_SME_Client.conf <<EOF
client
remote $SERVER_IP 1194
dev tun
proto udp
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert ${CLIENT_Name}.crt
key ${CLIENT_Name}.key
remote-cert-tls server
tls-auth ta.key 1
verb 3
EOF

echo "Setting File Permissions..."
chmod 600 /etc/openvpn/*.key
chmod 600 /etc/openvpn/*.crt

echo "Starting OpenVPN Client..."
sudo systemctl enable openvpn@UTS_SME_Client
sudo systemctl start openvpn@UTS_SME_Client

echo "Client Setup Complete."
