#!/bin/bash

# Exit on error
set -e

# Default topic (can be overridden by command line)
NTFY_TOPIC=${1:-""}

# Ask for topic if not provided
if [ -z "$NTFY_TOPIC" ]; then
    read -p "Enter your ntfy.sh topic name (must be unique and secure): " NTFY_TOPIC
    if [ -z "$NTFY_TOPIC" ]; then
        echo "No topic provided. Using a random topic name."
        NTFY_TOPIC="ssh-notify-$(head /dev/urandom | tr -dc a-z0-9 | head -c 12)"
        echo "Your topic is: $NTFY_TOPIC"
        echo "IMPORTANT: Save this topic name to subscribe to notifications!"
    fi
fi

# Script locations
SCRIPT_DIR="/opt/ssh-login-notify"
CONFIG_DIR="/etc/ssh-login-notify"
SCRIPT_PATH="$SCRIPT_DIR/ssh_login_notify.sh"
CONFIG_PATH="$CONFIG_DIR/config"
SERVICE_PATH="/etc/systemd/system/ssh-login-notify.service"

# Create directories
sudo mkdir -p $SCRIPT_DIR
sudo mkdir -p $CONFIG_DIR

# Copy script
sudo cp ./ssh_login_notify.sh $SCRIPT_PATH
sudo chmod +x $SCRIPT_PATH

# Create config file
echo "Creating configuration..."
echo "# SSH Login Notify Configuration" | sudo tee $CONFIG_PATH
echo "NTFY_TOPIC=\"$NTFY_TOPIC\"" | sudo tee -a $CONFIG_PATH
echo "NTFY_URL=\"https://ntfy.sh/\$NTFY_TOPIC\"" | sudo tee -a $CONFIG_PATH
echo "LOG_FILE=\"/var/log/auth.log\"" | sudo tee -a $CONFIG_PATH

# Create systemd service
echo "Creating systemd service..."
cat > /tmp/ssh-login-notify.service << EOF
[Unit]
Description=SSH Login Notification Service
After=network.target

[Service]
Type=simple
ExecStart=$SCRIPT_PATH --topic=$NTFY_TOPIC
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/ssh-login-notify.service $SERVICE_PATH

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable ssh-login-notify.service
sudo systemctl start ssh-login-notify.service

echo "Installation completed!"
echo "Your ntfy.sh topic is: $NTFY_TOPIC"
echo "Subscribe to notifications at: https://ntfy.sh/$NTFY_TOPIC"
echo "To change settings, edit: $CONFIG_PATH"
echo "Restart service with: sudo systemctl restart ssh-login-notify.service"
echo "Check service status with: sudo systemctl status ssh-login-notify.service"
