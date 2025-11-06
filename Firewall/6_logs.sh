#!/bin/bash
LOG_FILE="/var/log/firewall.log"

echo "Showing last 10 log entries: "
sudo tail -n 10 "$LOG_FILE"

