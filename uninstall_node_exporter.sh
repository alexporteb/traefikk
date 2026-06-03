#!/bin/bash
set -e

echo "Starting node_exporter uninstallation..."

# 1. Determine privilege escalation method
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "Error: This script must be run as root or with sudo privileges."
    exit 1
  fi
fi

# 2. Stop and disable service safely
echo "Stopping systemd service..."
if systemctl is-active --quiet node_exporter; then
    $SUDO systemctl stop node_exporter
fi
if systemctl is-enabled --quiet node_exporter; then
    $SUDO systemctl disable node_exporter
fi

# 3. Remove systemd service file
echo "Removing service files..."
if [ -f /etc/systemd/system/node_exporter.service ]; then
    $SUDO rm -f /etc/systemd/system/node_exporter.service
    $SUDO systemctl daemon-reload
fi

# 4. Remove binary
echo "Removing binary..."
if [ -f /usr/local/bin/node_exporter ]; then
    $SUDO rm -f /usr/local/bin/node_exporter
fi

# 5. Remove user safely
echo "Removing user..."
if id -u node_exporter &>/dev/null; then
    $SUDO userdel node_exporter
fi

echo "✅ node_exporter successfully uninstalled and completely removed from the system!"
