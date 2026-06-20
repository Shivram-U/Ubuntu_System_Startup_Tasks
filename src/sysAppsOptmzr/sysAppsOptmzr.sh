#!/bin/bash
# ============================================================
# Ubuntu System Applications Optimizer (Colored Output Version)
# ============================================================

set -e

# ----------------------------
# Color definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}Starting system optimization...${NC}\n"

# ------------------------------------------------------------
# 1. Update package index
# ------------------------------------------------------------
echo -e "${BLUE}Updating package lists...${NC}"
sudo apt update


# ------------------------------------------------------------
# 2. Upgrade packages
# ------------------------------------------------------------
echo -e "\n${BLUE}Upgrading installed packages...${NC}"
sudo apt upgrade -y


# ------------------------------------------------------------
# 3. Remove unnecessary dependencies
# ------------------------------------------------------------
echo -e "\n${YELLOW}Removing unused dependencies and residual packages...${NC}"
sudo apt-get autoremove --purge -y


# ------------------------------------------------------------
# 4. Clean APT cache
# ------------------------------------------------------------
echo -e "\n${YELLOW}Cleaning APT cache...${NC}"
sudo apt autoclean
sudo apt clean


# ------------------------------------------------------------
# 5. Remove leftover config files
# ------------------------------------------------------------
echo -e "\n${YELLOW}Purging leftover configuration files...${NC}"
dpkg -l | awk '/^rc/ {print $2}' | xargs -r sudo apt purge -y


# ------------------------------------------------------------
# 6. Disk usage check
# ------------------------------------------------------------
echo -e "\n${BLUE}APT cache size:${NC}"
sudo du -sh /var/cache/apt 2>/dev/null

echo -e "${BLUE}APT lists size:${NC}"
sudo du -sh /var/lib/apt/lists 2>/dev/null


# ------------------------------------------------------------
# 7. Clear crash reports
# ------------------------------------------------------------
echo -e "\n${RED}Clearing crash reports...${NC}"
sudo rm -rf /var/crash/*
echo -e "${GREEN}Crash reports cleared${NC}"


# ------------------------------------------------------------
# 8. Clean system logs
# ------------------------------------------------------------
echo -e "\n${RED}Cleaning systemd journal logs (100MB limit)...${NC}"
sudo journalctl --vacuum-size=100M >/dev/null 2>&1
echo -e "${GREEN}Journal logs cleaned${NC}"


# ------------------------------------------------------------
# DONE
# ------------------------------------------------------------
echo -e "\n${GREEN}Optimization completed successfully!${NC}\n"
