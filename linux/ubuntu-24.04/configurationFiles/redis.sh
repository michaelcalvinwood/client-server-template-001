#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Exit on any error
set -e

echo "===== Redis Installation Script for Ubuntu 24.04 ====="

# Load configuration values from server.conf
if [ ! -f server.conf ]; then
    echo "Error: server.conf file not found"
    exit 1
fi

# Read values using grep and cut
serviceIp=$(grep "^serviceIp=" server.conf | cut -d'=' -f2)

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Updating package lists..."
apt update

echo "Installing Redis..."
apt install -y redis-server

# Generate a secure random password
echo "Generating secure random password..."
REDIS_PASSWORD=$(openssl rand -hex 64)
echo "Password generated successfully."

# Add password to server.conf
echo "Adding password to server.conf..."
if [ -f /root/server.conf ]; then
    echo "redisPassword=${REDIS_PASSWORD}" >> /root/server.conf
    echo "Password added to server.conf."
else
    echo "Warning: /root/server.conf not found. Creating it."
    echo "redisPassword=${REDIS_PASSWORD}" > /root/server.conf
    echo "Created server.conf with password."
fi

# Configure Redis to use the password and disable persistence
echo "Configuring Redis..."
REDIS_CONF="/etc/redis/redis.conf"

# Backup original config
cp $REDIS_CONF "${REDIS_CONF}.bak"

# Set password
sed -i "s/^# requirepass.*$/requirepass ${REDIS_PASSWORD}/" $REDIS_CONF
if ! grep -q "^requirepass" $REDIS_CONF; then
    echo "requirepass ${REDIS_PASSWORD}" >> $REDIS_CONF
fi

# Configure Redis to bind to all network interfaces ($serviceIp)
echo "Configuring Redis to bind to all interfaces ($serviceIp)..."

# Check if bind directive exists in any form
if grep -q "^bind" $REDIS_CONF; then
    # Replace existing bind directive with the new one
    sed -i "s/^bind.*$/bind $serviceIp/" $REDIS_CONF
else
    # If bind directive doesn't exist, add it
    echo "bind $serviceIp" >> $REDIS_CONF
fi

# Ensure protected mode is disabled when binding to all interfaces
sed -i "s/^protected-mode yes/protected-mode no/" $REDIS_CONF

# Disable persistence by setting all persistence options to no
sed -i 's/^save/# save/g' $REDIS_CONF
echo "# Disable persistence" >> $REDIS_CONF
echo "save \"\"" >> $REDIS_CONF
sed -i 's/^appendonly yes/appendonly no/' $REDIS_CONF

# Restart Redis to apply changes
echo "Restarting Redis service..."
systemctl restart redis-server

# Verify Redis is running
if systemctl is-active --quiet redis-server; then
    echo "Redis installed and configured successfully!"
    echo "Password has been set and saved to server.conf"
    echo "Persistence has been disabled."
else
    echo "Error: Redis service failed to start. Check logs with 'journalctl -u redis-server'"
    exit 1
fi

echo "===== Installation Complete ====="