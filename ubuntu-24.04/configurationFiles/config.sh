#!/bin/bash

# Check if server.conf exists and contains dbPassword
if [ -f server.conf ] && grep -q "^dbPassword=" server.conf; then
    echo "dbPassword already exists in server.conf, skipping password creation"
else
    # Create a password using openssl rand -hex 16
    password=$(openssl rand -hex 16)

    # If server.conf doesn't exist, create it
    if [ ! -f server.conf ]; then
        touch server.conf
    fi

    # Append dbPassword={password} to server.conf
    echo "dbPassword=$password" >> server.conf
    echo "Added new dbPassword to server.conf"
fi

# Load configuration values from server.conf
if [ ! -f server.conf ]; then
    echo "Error: server.conf file not found"
    exit 1
fi

# Read values using grep and cut
domain=$(grep "^domain=" server.conf | cut -d'=' -f2)
email=$(grep "^email=" server.conf | cut -d'=' -f2)
dbPassword=$(grep "^dbPassword=" server.conf | cut -d'=' -f2)

# Validate required values
if [ -z "$domain" ]; then
    echo "Error: domain not found in server.conf"
    exit 1
fi

if [ -z "$email" ]; then
    echo "Error: email not found in server.conf"
    exit 1
fi

if [ -z "$dbPassword" ]; then
    echo "Error: dbPassword not found in server.conf"
    exit 1
fi

# If we reach here, all required values were found
echo "Successfully loaded configuration values"


