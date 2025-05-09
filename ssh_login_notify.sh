#!/bin/bash

# Configuration defaults
CONFIG_FILE="/etc/ssh-login-notify/config"
LOG_FILE="/var/log/auth.log"
NTFY_TOPIC="your-secure-topic"  # Default value

# Process command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --topic=*)
        NTFY_TOPIC="${1#*=}"
        shift
        ;;
        --log=*)
        LOG_FILE="${1#*=}"
        shift
        ;;
        *)
        # Unknown option
        echo "Unknown option: $1"
        echo "Usage: $0 [--topic=TOPIC_NAME] [--log=LOG_FILE_PATH]"
        exit 1
        ;;
    esac
done

# Load config file if exists (will override defaults but not command line args)
if [ -f "$CONFIG_FILE" ]; then
    # Only read config if no command line args provided
    if [[ "$*" != *"--topic="* ]]; then
        source "$CONFIG_FILE"
    fi
fi

NTFY_URL="https://ntfy.sh/$NTFY_TOPIC"
HOSTNAME=$(hostname)

echo "Starting SSH login notification service..."
echo "Monitoring: $LOG_FILE"
echo "Sending notifications to: $NTFY_URL"

# Set up trap for SSH logins
tail -n0 -F $LOG_FILE | while read line
do
    if echo "$line" | grep -q "sshd.*Accepted"; then
        # Extract username and IP address
        USERNAME=$(echo "$line" | grep -oP "for \K\w+" | head -1)
        IP_ADDRESS=$(echo "$line" | grep -oP "from \K[0-9.]+" | head -1)
        DATE=$(date "+%Y-%m-%d %H:%M:%S")
        
        # Send notification via ntfy.sh
        curl -H "Title: SSH Login on $HOSTNAME" \
             -H "Priority: high" \
             -H "Tags: warning,ssh,login" \
             -d "User '$USERNAME' logged in from $IP_ADDRESS at $DATE" \
             "$NTFY_URL"
    fi
done
