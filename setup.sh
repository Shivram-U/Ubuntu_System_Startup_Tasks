### Linux startup procedure setup script ###
echo -e "Linux startup procedure setup script\n\n";

# Setup directory
INSTL_DIR="/system_startup_tasks";
mkdir -p $INSTL_DIR/;

# Environment variables setup

VAR1="SYSTEM_STARTUP_TASKS_SRC";
VAR2="SYSTEM_STARTUP_TASKS_EXEC";

VAR_FILE="/etc/environment";

# Remove existing entry if present
# grep -q "^${VAR1}=" /etc/environment && echo "Present" || echo "Not present"

sudo sed -i "/^${VAR1}=/d" "$VAR_FILE";
sudo sed -i "/^${VAR2}=/d" "$VAR_FILE";

echo "$VAR1=\"$INSTL_DIR\"" | sudo tee -a $VAR_FILE > /dev/null
echo "$VAR2=\"$INSTL_DIR/system_startup_tasks.sh\"" | sudo tee -a $VAR_FILE > /dev/null

source "$VAR_FILE";

# Setup
cp -r src/* "$SYSTEM_STARTUP_TASKS_SRC";

chmod -R +x "$SYSTEM_STARTUP_TASKS_SRC"/*;

# Startup script setup

#!/bin/bash

# mkdir -p /etc/xdg/autostart

# sudo tee /etc/xdg/autostart/system_startup_tasks.desktop > /dev/null <<EOF
# [Desktop Entry]
# Type=Application
# Name=System Startup Tasks
# Exec=gnome-terminal -- bash -c "$SYSTEM_STARTUP_TASKS_EXEC; exec bash"
# Terminal=false
# X-GNOME-Autostart-enabled=true
# EOF

bash -c 'echo -e "[Unit]\nDescription=System Startup Procedure\n\n[Service]\nExecStart=$SYSTEM_STARTUP_TASKS_SRC/system_startup_tasks.sh\nRestart=always\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/system_startup.service && systemctl daemon-reexec && systemctl enable system_startup.service'

# Start the system startup service to execute the startup script during system boot
# systemctl start system_startup.service;

#!/bin/bash

SERVICE_NAME="system_startup_tasks"
SCRIPT_PATH="/system_startup_tasks/system_startup_tasks.sh"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Ensure script exists
if [ ! -f "$SYSTEM_STARTUP_TASKS_EXEC" ]; then
    echo "Error: $SYSTEM_STARTUP_TASKS_EXEC does not exist."
    exit 1
fi

# Make script executable
chmod +x "$SYSTEM_STARTUP_TASKS_EXEC"

# Create systemd service
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=System Startup Tasks
After=network.target

[Service]
Type=simple
ExecStart=$SCRIPT_PATH
Restart=no

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload

# Enable service at boot
systemctl enable "${SERVICE_NAME}.service"

# Start service immediately
systemctl start "${SERVICE_NAME}.service"

# Show status
systemctl status "${SERVICE_NAME}.service" --no-pager

echo
echo "Service installed and enabled successfully."
echo "Check logs with:"
echo "journalctl -u ${SERVICE_NAME}.service -b"


echo -e "\n\nsetup completed";

