#!/bin/bash
LOG_FILE="/var/log/firewall.log"

echo "Firewall Live Log "
sudo tail -f "$LOG_FILE"

