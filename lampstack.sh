#!/bin/bash
sudo yum update -y
sudo yum install -y httpd wget php-fpm php-mysqli php-json php php-devel
sudo yum install mariadb105-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
sudo yum install php-mbstring php-xml -y
sudo systemctl restart httpd
sudo systemctl restart php-fpm
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
sudo rm phpMyAdmin-latest-all-languages.tar.gz
sudo systemctl start mariadb
sudo mysql_secure_installation <<SECURE_INSTALLATION
y
shinu@143
shinu@143
y
y
y
y
SECURE_INSTALLATION
# Configure PHP timezone (optional)
sed -i 's/;date.timezone =/date.timezone = America\/New_York/g' /etc/php.ini

# Restart Apache for PHP to take effect
sudo systemctl restart httpd
