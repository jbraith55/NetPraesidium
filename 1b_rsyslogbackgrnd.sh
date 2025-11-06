#!/bin/bash
sudo tee /etc/rsyslog.d/20-nftables.conf > /dev/null <<EOF
:msg, contains, "FW_INPUT_DROP" /var/log/firewall.log
:msg, contains, "SYN_SCAN_DROP" /var/log/firewall.log
& stop
EOF

sudo systemctl restart rsyslog
echo "Rsyslog configured and restarted for nftables logging"

