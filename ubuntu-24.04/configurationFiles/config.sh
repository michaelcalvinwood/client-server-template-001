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

# Install and Configure nginx
DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y nginx libnginx-mod-http-headers-more-filter
sudo ufw app list
sudo ufw allow 'Nginx HTTP'

sudo mkdir /var/www/$domain

sudo chown -R $USER:$USER /var/www/$domain

printf "server {
    listen 80;
    server_name $domain www.$domain;
    root /var/www/$domain;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_read_timeout 600;
        fastcgi_send_timeout 600;
        fastcgi_connect_timeout 600;
     }

    location ~ /\.ht {
        deny all;
    }

}" > /etc/nginx/sites-available/$domain

sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/

sudo unlink /etc/nginx/sites-enabled/default

sudo nginx -t

sudo systemctl reload nginx

printf "<html>
  <head>
    <title>your_domain website</title>
  </head>
  <body>
    <h1>Hello World!</h1>

    <p>This is the landing page of <strong>$domain</strong>.</p>
  </body>
</html>" > /var/www/$domain/index.html
