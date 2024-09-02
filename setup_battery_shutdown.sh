#!/bin/bash

# Define the script path
SCRIPT_PATH="/usr/local/bin/battery_shutdown.sh"

# Define the service file path
SERVICE_FILE="/etc/systemd/system/battery_shutdown.service"

# Create the script file
cat << 'EOF' > $SCRIPT_PATH
#!/bin/bash

while true; do
    # Check if Proxmox server is connected to AC power
    ac_power=$(cat /sys/class/power_supply/ADP1/online)

    # Check battery level if not connected to AC power
    if [ "$ac_power" -eq 0 ]; then
        battery_level=$(cat /sys/class/power_supply/BAT1/capacity)

        # Check if battery level is below 25%
        if [ "$battery_level" -lt 25 ]; then
            # Shutdown gracefully
            echo "Battery level is below 25% and AC power is not connected. Initiating graceful shutdown..."
            shutdown -h now
        else
            echo "Battery level is above 25%. No action required."
        fi
    else
        echo "AC power is connected. No action required."
    fi

    # Wait for a period of time before checking again (e.g., 1 minute)
    sleep 60
done
EOF

# Make the script executable
chmod +x $SCRIPT_PATH

# Create the systemd service file
cat << 'EOF' > $SERVICE_FILE
[Unit]
Description=Battery Shutdown Monitor Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/battery_shutdown.sh
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
systemctl daemon-reload

# Enable the service to start on boot
systemctl enable battery_shutdown.service

# Start the service
systemctl start battery_shutdown.service

# Print the status of the service
systemctl status battery_shutdown.service
