#!/bin/bash
# Memory & Storage Optimizer
# Usage: sudo ./memory_optimize.sh
# Description:
#   This script optimizes system memory (RAM + swap) and SSD storage.
#   It also reports the largest files/directories consuming space.

echo -e "\n------------------------------------";
echo -e "Starting memory and storage optimization... ($(date))";
echo -e "------------------------------------";

# Trim unused blocks on SSD for better performance
echo -e "\nTrimming unused blocks on SSD (fstrim)...";
sudo fstrim -v /;
sudo fstrim -av;
echo -e "completed\n";

# Free memory by clearing inactive swap
echo -e "\nClearing inactive swap to free RAM...";
if swapon --show | grep -q '/swapfile'; then
    echo "Swapfile is active, skipping swapoff/swapon..."
else
    echo "Swapfile not active, enabling it..."
    sudo swapon /swapfile
fi
echo -e "completed\n";

# Clear PageCache, dentries, and inodes to free RAM
echo -e "\nClearing PageCache, dentries, and inodes to free memory...";
sudo sync;
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches';
echo -e "completed\n";

# Show memory usage after cleanup
echo -e "\nCurrent memory usage:";
free -h;

# Show disk usage to verify trim
echo -e "\nDisk usage after trim:";
df -h /;

# Show top 20 largest files/directories
echo -e "\nTop 20 largest files/directories consuming space:";
sudo du -ahx / | sort -rh | head -n 20;

echo -e "\nMemory and storage optimization completed!\n";

