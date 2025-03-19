#!/bin/bash
# Exit on error
set -e

# Print commands before executing
set -x

# Make sure we are root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Configure dpkg to keep existing config files
export DEBIAN_FRONTEND=noninteractive
echo 'Dpkg::Options {"--force-confdef";"--force-confold";}' > /etc/apt/apt.conf.d/local

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
apt-get update -y -q
apt-get upgrade -y -q
apt-get install -y -q nginx libnginx-mod-http-headers-more-filter
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
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
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

# Install PHP
echo "Installing prerequisite packages..."
apt-get install -y -q software-properties-common apt-transport-https curl

echo "Adding Ondřej Surý's PPA for PHP..."
add-apt-repository -y ppa:ondrej/php

echo "Updating package lists again..."
apt-get update -y -q

echo "Installing PHP 8.3 FPM and common extensions required for WordPress..."
apt-get install -y -q php8.3-fpm php8.3-common php8.3-mysql php8.3-xml php8.3-xmlrpc \
    php8.3-curl php8.3-gd php8.3-imagick php8.3-cli php8.3-dev php8.3-imap \
    php8.3-mbstring php8.3-opcache php8.3-soap php8.3-zip php8.3-intl php8.3-bcmath

# Configure PHP settings for WordPress
PHP_INI="/etc/php/8.3/fpm/php.ini"

echo "Configuring PHP for WordPress requirements..."

# Create a backup of the original php.ini
cp $PHP_INI "${PHP_INI}.backup"

# Update PHP settings for WordPress
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $PHP_INI
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' $PHP_INI
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' $PHP_INI
sed -i 's/memory_limit = 128M/memory_limit = 256M/g' $PHP_INI
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $PHP_INI
sed -i 's/max_input_time = 60/max_input_time = 300/g' $PHP_INI

# Configure OpCache for better performance
sed -i 's/;opcache.enable=1/opcache.enable=1/g' $PHP_INI
sed -i 's/;opcache.memory_consumption=128/opcache.memory_consumption=256/g' $PHP_INI
sed -i 's/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=16/g' $PHP_INI
sed -i 's/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=20000/g' $PHP_INI
sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=360/g' $PHP_INI
sed -i 's/;opcache.fast_shutdown=0/opcache.fast_shutdown=1/g' $PHP_INI

# Restart PHP-FPM
echo "Restarting PHP 8.3 FPM service..."
systemctl restart php8.3-fpm

# Verify installation
PHP_VERSION=$(php -r 'echo phpversion();')
echo "PHP $PHP_VERSION has been installed and configured for WordPress."

echo "PHP-FPM status:"
systemctl status php8.3-fpm --no-pager

echo "Installation completed successfully."

printf "<?php
echo 'hello PHP';
?>" > /var/www/$domain/test.php

printf "<?php
phpinfo();
?>" > /var/www/$domain/info.php

# Install MYSQL

# Install MySQL non-interactively
export DEBIAN_FRONTEND=noninteractive
apt-get install -y mysql-server

# Start MySQL service
systemctl start mysql
systemctl enable mysql

# Secure MySQL installation - set root password
mysql --user=root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$dbPassword';
FLUSH PRIVILEGES;
EOF

sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Create root@% user that can connect from any host with the same password
mysql --user=root --password="$dbPassword" <<EOF
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$dbPassword';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Restart MySQL for changes to take effect
systemctl restart mysql

echo "MySQL has been installed and configured to listen on 0.0.0.0"
echo "Root password has been set and remote access enabled."

echo "MySQL has been installed and root password has been set successfully."

