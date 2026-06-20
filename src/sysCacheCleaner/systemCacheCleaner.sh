#!/bin/bash
# ============================================================
# Cache Cleanup Optimizer (Safe + Colored Output Version)
# ============================================================

set -euo pipefail

INTERVAL=3600  # 1 hour loop interval

# ----------------------------
# Colors
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ----------------------------
# Function: clear_cache
# ----------------------------
clear_cache() {
    echo -e "\n${CYAN}------------------------------------${NC}"
    echo -e "${CYAN}Cleaning system caches... ($(date))${NC}"
    echo -e "${CYAN}------------------------------------${NC}"

    # --------------------------------------------------------
    # 1. Drop system memory caches (PageCache, dentries, inodes)
    # --------------------------------------------------------
    echo -e "\n${BLUE}Clearing RAM cache (PageCache, dentries, inodes)...${NC}"
    sudo sync
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    echo -e "${GREEN}Memory cache cleared${NC}"


    # --------------------------------------------------------
    # 2. APT cache cleanup
    # --------------------------------------------------------
    echo -e "\n${BLUE}Cleaning APT cache...${NC}"
    sudo apt-get clean
    sudo apt-get autoclean
    echo -e "${GREEN}APT cache cleaned${NC}"


    # --------------------------------------------------------
    # 3. Systemd journal logs cleanup
    # --------------------------------------------------------
    echo -e "\n${BLUE}Cleaning systemd journal logs (older than 2 days)...${NC}"
    sudo journalctl --vacuum-time=2d >/dev/null 2>&1
    echo -e "${GREEN}Journal logs cleaned${NC}"


    # --------------------------------------------------------
    # 4. Thumbnail cache cleanup
    # --------------------------------------------------------
    echo -e "\n${BLUE}Clearing thumbnail cache...${NC}"
    rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
    echo -e "${GREEN}Thumbnail cache cleared${NC}"


    # --------------------------------------------------------
    # 5. Temporary files cleanup
    # --------------------------------------------------------
    echo -e "\n${YELLOW}Clearing temporary files (/tmp and /var/tmp)...${NC}"

    # Safer cleanup (avoid deleting critical mounted temp files)
    sudo find /tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
    sudo find /var/tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true

    echo -e "${GREEN}Temporary files cleaned${NC}"


    echo -e "\n${GREEN}Cache cleanup completed successfully!${NC}"
}

# ----------------------------
# Mode selection
# ----------------------------
MODE=${1:-once}

# ----------------------------
# Single run mode
# ----------------------------
if [[ "$MODE" == "once" ]]; then
    clear_cache
    echo -e "\n${CYAN}Finished single-run cleanup.${NC}\n"
    exit 0
fi

# ----------------------------
# Loop mode
# ----------------------------
echo -e "\n${CYAN}Cache cleanup will run every $((INTERVAL/60)) minutes...${NC}\n"

while true; do
    clear_cache
    echo -e "\n${YELLOW}Waiting $((INTERVAL/60)) minutes before next cleanup...${NC}"
    sleep "$INTERVAL"
done
