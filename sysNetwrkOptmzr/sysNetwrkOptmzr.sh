#!/bin/bash
# Network Optimizer Script
# Usage: sudo ./network_optimize.sh
# Description:
#   This script reloads the system network modules, restarts NetworkManager,
#   and clears the DNS cache to improve network performance and resolve issues.
#   Optional: flushes ARP cache and resets networking interfaces if needed.

echo -e "\n------------------------------------";
echo -e "Starting network optimization... ($(date))";
echo -e "------------------------------------";

# Restart NetworkManager service
echo -e "\nRestarting NetworkManager service...";
sudo systemctl restart NetworkManager.service;
echo -e "completed\n";

# Flush DNS cache
echo -e "\nFlushing DNS cache...";
sudo resolvectl flush-caches;
echo -e "completed\n";

# Optional: Flush ARP cache (clears outdated MAC-IP mappings)
# echo -e "\nFlushing ARP cache...";
# sudo ip -s -s neigh flush all;
# echo -e "completed\n";

# Optional: Restart all network interfaces (use only if needed)
# echo -e "\nRestarting all network interfaces...";
# sudo ifdown -a && sudo ifup -a;
# echo -e "completed\n";

echo -e "\nNetwork optimization completed!\n";

