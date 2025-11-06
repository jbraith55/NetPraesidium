#!/bin/bash

# This file excecutes all firewall scripts. For ease of use, the 7th firewall script (live logs) was not used as is not required in setup. 

echo "Commencing firewall setup"

bash ./Firewall/1_Packages.sh
bash ./Firewall/2_rsyslogbackgrnd.sh
bash ./Firewall/3_flush.sh
bash ./Firewall/4_rules.sh
bash ./Firewall/5_check.sh
bash ./Firewall/6_logs.sh

echo "Firewall setup complete."
