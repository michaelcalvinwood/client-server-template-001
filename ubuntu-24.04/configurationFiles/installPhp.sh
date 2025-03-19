# Install and Config PHP

sudo apt install -y php8.1-fpm php-mysql

sudo mv php.ini /etc/php/8.1/fpm/php.ini
sudo systemctl restart php8.1-fpm.service
sudo systemctl reload php8.1-fpm.service

printf "<?php
phpinfo();" > /var/www/$Domain/info.php