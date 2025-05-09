# SSH Login Notifier

A simple, lightweight script that sends notifications via [ntfy.sh](https://ntfy.sh) whenever someone logs into your SSH server. Get real-time alerts about SSH logins directly on your phone or browser.

![SSH Login Notification Example](https://ntfy.sh/_next/static/media/logo.077f6a13.svg)

## Features

- Real-time notifications for SSH logins
- Captures username and IP address of the person logging in
- Easy setup via the installation script
- Runs as a systemd service
- Configurable without modifying the script

## Requirements

- Linux server with systemd
- Bash shell
- `curl` command installed
- Access to /var/log/auth.log (or equivalent SSH log file)

## Quick Installation

1. Clone this repository:

```bash
git clone https://github.com/linuxmaster14/ssh-login-notify.git
cd ssh-login-notify
```

2. Run the installation script with an optional topic name:

```bash
chmod +x install.sh
sudo ./install.sh
```

If you don't provide a topic name, the script will ask for one or generate a random one.

3. The script will display your ntfy.sh topic. Subscribe to this topic to receive notifications.

4. If needed, you can modify settings:

```
sudo vim /etc/ssh-login-notify/config
sudo systemctl restart ssh-login-notify.service
```

## Receiving Notifications

You can receive notifications in several ways:

1. Web browser: Visit https://ntfy.sh/your-topic-name

2. Mobile app: Download the ntfy app for Android or iOS and subscribe to your topic

3. Command line: `curl -s https://ntfy.sh/your-topic-name/json`

## Manual Installation

If you prefer to install manually:

1. Place the script in `/opt/ssh-login-notify/ssh_login_notify.sh`

2. Make it executable: `chmod +x /opt/ssh-login-notify/ssh_login_notify.sh`

3. Create config directory: `mkdir -p /etc/ssh-login-notify`

4. Create a config file: nano `/etc/ssh-login-notify/config` with the following content:

```bash
NTFY_TOPIC="your-secure-topic"
NTFY_URL="https://ntfy.sh/$NTFY_TOPIC"
LOG_FILE="/var/log/auth.log"
```

5. Create a systemd service file at `/etc/systemd/system/ssh-login-notify.service` with:

```
[Unit]
Description=SSH Login Notification Service
After=network.target

[Service]
Type=simple
ExecStart=/opt/ssh-login-notify/ssh_login_notify.sh --topic=your-secure-topic
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

6. Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable ssh-login-notify.service
sudo systemctl start ssh-login-notify.service
```

## Troubleshooting

Check the service status:

```bash
sudo systemctl status ssh-login-notify.service
```

View the logs:

```bash
sudo journalctl -u ssh-login-notify.service
```

Check if your log file path is correct in the config file. Different distributions may use different paths:

- Ubuntu/Debian: `/var/log/auth.log`
- CentOS/RHEL: `/var/log/secure`

## Uninstallation

To remove the script and all its components:

```bash
chmod +x uninstall.sh
sudo ./uninstall.sh
```

The uninstall script will:

1. Stop and disable the service
2. Remove the service file
3. Remove the script files
4. Remove all configuration files

## What is NTFY_TOPIC?

The NTFY_TOPIC is a unique identifier for your notification channel on ntfy.sh. It works like a "channel name" that you subscribe to for receiving notifications.

For security:

- Use a random, complex string that others can't guess

- Keep your topic private - anyone with the topic name can see your notifications

- You can change your topic anytime by editing the config file and restarting the service

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

This project is licensed under the MIT License - see the LICENSE file for details.