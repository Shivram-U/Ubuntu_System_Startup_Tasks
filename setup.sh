### Linux startup procedure setup script ###
echo "Linux startup procedure setup script\n\n";

# Setup directory
INSTL_DIR="/system_startup_tasks";
mkdir -p $INSTL_DIR/;

# Environment variables setup

VAR1="SYSTEM_STARTUP_TASKS_SRC";
VAR2="SYSTEM_STARTUP_TASKS_EXEC";

FILE="/etc/environment";

# Remove existing entry if present
sudo sed -i "/^export $VAR1=/d" "$FILE" 2>/dev/null
sudo sed -i "/^export $VAR2=/d" "$FILE" 2>/dev/null

echo "$VAR1=\"/system_startup_tasks\"" | sudo tee -a /etc/environment > /dev/null
echo "$VAR2=\"/usr/local/bin/system_startup_tasks.sh\"" | sudo tee -a /etc/environment > /dev/null

# Setup
cp src/* SYSTEM_STARTUP;

chmod SYSTEM_STARTUP/*;

# Startup script setup

bash -c 'echo -e "[Unit]\nDescription=System Startup Procedure\n\n[Service]\nExecStart=/usr/local/bin/system_startup/startup.sh\nRestart=always\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/system_startup.service && systemctl daemon-reexec && systemctl enable system_startup.service'

# Start the system startup service to execute the startup script during system boot
systemctl start system_startup.service;

echo "\n\nsetup completed";

