#!/bin/bash

# Exit on error
set -e

# Script locations
SCRIPT_DIR="/opt/ssh-login-notify"
CONFIG_DIR="/etc/ssh-login-notify"
SERVICE_PATH="/etc/systemd/system/ssh-login-notify.service"

# Check if service is running and stop it
if systemctl is-active --quiet ssh-login-notify.service; then
    echo "Stopping ssh-login-notify service..."
    sudo systemctl stop ssh-login-notify.service
fi

# Disable service
if systemctl is-enabled --quiet ssh-login-notify.service; then
    echo "Disabling ssh-login-notify service..."
    sudo systemctl disable ssh-login-notify.service
fi

# Remove service file
if [ -f "$SERVICE_PATH" ]; then
    echo "Removing systemd service file..."
    sudo rm -f $SERVICE_PATH
    sudo systemctl daemon-reload
fi

# Remove script and configuration
echo "Removing script files..."
sudo rm -rf $SCRIPT_DIR

# Remove configuration files
echo "Removing configuration files..."
sudo rm -rf $CONFIG_DIR

echo "Uninstallation completed! All files have been removed."
