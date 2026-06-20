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

# Start the system startup service to execute the startup script during system boot

mkdir -p /etc/xdg/autostart

sudo tee /etc/xdg/autostart/system_startup_tasks.desktop > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=System Startup Tasks
Comment=Runs system startup tasks after login
Exec=gnome-terminal -- bash -c "$SYSTEM_STARTUP_TASKS_EXEC; exec bash"
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

echo -e "\n\nsetup completed";

# References
# gnome-terminal -- sh -c "bash -c \"/$STARTUP_TASKS_EXEC; exec bash\""
# /$STP  -> do not use . it refers to current directory
