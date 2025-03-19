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
