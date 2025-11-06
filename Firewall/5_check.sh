#!/bin/bash
echo "Firewall status: "
sudo systemctl is-active --quiet nftables && echo "NFTables: Active" || echo "NFTables: Inactive"

echo "Displaying current tables and chains: "
sudo nft list ruleset

