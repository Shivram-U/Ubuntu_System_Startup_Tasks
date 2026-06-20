#!/bin/bash
# Master Startup Script
# Description:
#   This script runs at system startup to display system info, confirm sudo access,
#   and execute optimization scripts in an integrated order.
#   Scripts include cache cleanup, system applications optimizer, memory optimizer,
#   network optimizer, and log rotation.

# ------------------------
# Navigate to root directory
# ------------------------
cd $SYSTEM_STARTUP_TASKS_SRC;

# ------------------------
# Display System Information
# ------------------------
neofetch;
echo -e "\n\n\nWelcome, $(whoami)! | Date & Time: $(date '+%Y-%m-%d %H:%M:%S') | Uptime: $(uptime -p) | Disk usage: $(df -h / | awk 'NR==2{print $5}') | CPU load: $(uptime | awk -F'load average:' '{print $2}') | Memory usage: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')";
echo -e "\n\n\n";

# ------------------------
# Confirm Sudo Access (loop until granted)
# ------------------------
while true; do
    read -p "Do you have sudo access? If not, please obtain it now to proceed startup tasks [Y/y/N/n]: " response;
    if [[ "$response" == "Y" || "$response" == "y" ]]; then
        echo -e "Sudo access confirmed.\n";
        break;
    else
        echo -e "Sudo access is required to run the startup tasks. Please try again.";
    fi;
done

# Reload sudoers/users list
sudo -k;  # Invalidate cached sudo
sudo echo "Reloading sudo users list..." >/dev/null;

# Prompt for sudo password
sudo -v || { echo -e "Sudo required. Exiting."; exit 1; };
echo -e "Sudo access granted. Continuing startup tasks.\n";


# ------------------------
# System Setup
# ------------------------

echo "------------------------";
echo "System Setup";
echo -e "------------------------\n";

read -p "Do you want to stop the system logging services(rsyslog.service, syslog.socket) [Y/y/N/n] : " response;
if [[ "$response" == "Y" || "$response" == "y" ]]; then
	echo -e "Stopping system logging services...";
	sudo systemctl stop rsyslog.service syslog.socket;
	echo -e "System logging services stopped successfully.\n";
else
	echo -e "ok, proceeding to next step.\n";
fi;


# --------------------------------------------
# Integrated Optimization Execution
# --------------------------------------------

echo "--------------------------------------------";
echo "Integrated Optimization Execution";
echo -e "--------------------------------------------\n";

# 1. System Cache & temporary Files Cleanup
read -p "Proceed to clean system cache [Y/y/N/n] : " response;
if [[ "$response" == "Y" || "$response" == "y" ]]; then
	echo -e "Step 1: Cleaning system caches, temporary files, and thumbnails...";
	cd sysCacheCleaner/;
	sudo bash systemCacheCleaner.sh;
	echo -e "Step 1 completed: System caches and temporary files cleaned.\n";
else
	echo -e "ok, proceeding to next step.\n";
fi;

# 2. System Applications Optimization (APT packages & crash reports
read -p "Proceed to optimize system applications [Y/y/N/n] : " response;
if [[ "$response" == "Y" || "$response" == "y" ]]; then
	echo -e "Step 2: Optimizing installed applications and cleaning unnecessary packages...";
	cd ../sysAppsOptmzr/;
	sudo bash sysAppsOptmzr.sh;
	echo -e "Step 2 completed: Applications optimized and unnecessary packages removed.\n";
else
	echo -e "ok, proceeding to next step.\n";
fi;

# 3. Memory & Swap Optimization + SSD Trim
read -p "Proceed to optimize system memory, swap and secondary storage [Y/y/N/n] : " response;
if [[ "$response" == "Y" || "$response" == "y" ]]; then
	echo -e "Step 3: Optimizing system memory and swap, performing SSD trim...";
	cd ../sysStorageOptmzr/;
	sudo bash sysStorageOptmzr.sh;
	echo -e "Step 3 completed: Memory, swap, and SSD optimization done.\n";
else
	echo -e "ok, proceeding to next step.\n";
fi;
	
# 4. Network Optimization
read -p "Proceed to optimize system network modules and clean DNS cache [Y/y/N/n] : " response;
if [[ "$response" == "Y" || "$response" == "y" ]]; then
	echo -e "Step 4: Optimizing network modules and clearing DNS cache...";
	cd ../sysNetwrkOptmzr/;
	sudo bash sysNetwrkOptmzr.sh;
	echo -e "Step 4 completed: Network optimization finished.\n";
else
	echo -e "ok, proceeding to next step.\n";
fi;

echo -e "Launching additional task scripts in separate terminal tabs...\n";

# Declare an array of scripts with arguments
# Format: "script_path::arg1 arg2 ..."
SCRIPT_OBJECTS=(
    "sudo::/startup_tasks/sysCacheCleaner/systemCacheCleaner.sh::loop"
    "sudo::/startup_tasks/sysLogsCleaner/sysLogsRotator.sh::"
);

TERMINAL="gnome-terminal";

for ITEM in "${SCRIPT_OBJECTS[@]}"; do
    # Split the item into script path and arguments

    SUDO_ACCESS=$(awk -F'::' '{print $1}' <<< "$ITEM");
    SCRIPT_PATH=$(awk -F'::' '{print $2}' <<< "$ITEM");
    SCRIPT_ARGS=$(awk -F'::' '{print $3}' <<< "$ITEM");
    
    SCRIPT_DIR=$(dirname "$SCRIPT_PATH");
    SCRIPT_NAME=$(basename "$SCRIPT_PATH");

    echo -e "Starting task script: $SUDO_ACCESS $SCRIPT_NAME from $SCRIPT_DIR with args: $SCRIPT_ARGS...";

    # Execute script with args in a new terminal tab
    $TERMINAL --tab -- bash -c "cd \"$SCRIPT_DIR\" && $SUDO_ACCESS bash \"$SCRIPT_NAME\" $SCRIPT_ARGS; exec bash";

    echo -e "Task script $SCRIPT_NAME started in a new terminal tab.\n";
done

echo -e "All startup tasks and optimization scripts have been initiated successfully.\n";



