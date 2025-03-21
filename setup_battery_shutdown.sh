#!/bin/bash

# Define paths
SCRIPT_PATH="/usr/local/bin/battery_shutdown.sh"
SERVICE_FILE="/etc/systemd/system/battery_shutdown.service"

# Create the battery monitoring script
cat << 'EOF' > $SCRIPT_PATH
#!/bin/bash

# Paths for power supply info
AC_PATH="/sys/class/power_supply/ADP1/online"
BAT_PATH="/sys/class/power_supply/BAT1/capacity"

while true; do
    # Check if AC power file exists
    if [ -f "$AC_PATH" ]; then
        ac_power=$(cat "$AC_PATH")
    else
        echo "AC power status file not found!"
        ac_power=1  # Assume AC is connected to avoid false shutdowns
    fi

    # If AC power is disconnected
    if [ "$ac_power" -eq 0 ]; then
        if [ -f "$BAT_PATH" ]; then
            battery_level=$(cat "$BAT_PATH")

            # Shutdown if battery is below 25%
            if [ "$battery_level" -lt 25 ]; then
                echo "Battery low ($battery_level%). Initiating shutdown..."
                shutdown -h now
            else
                echo "Battery OK ($battery_level%). No shutdown."
            fi
        else
            echo "Battery capacity file not found!"
        fi
    else
        echo "AC power connected. No action required."
    fi

    # Wait for a period before checking again
    sleep 60
done
EOF

# Make the script executable
chmod +x $SCRIPT_PATH

# Create the systemd service file
cat << EOF > $SERVICE_FILE
[Unit]
Description=Battery Shutdown Monitor Service
After=multi-user.target

[Service]
Type=simple
ExecStart=$SCRIPT_PATH
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
