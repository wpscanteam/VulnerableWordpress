#!/bin/bash

/usr/bin/mysqld_safe &
sleep 10s
mysql -u root -e "CREATE DATABASE wordpress;"
mysql -u root -e "CREATE USER wordpress@localhost;"
mysql -u root -e "SET PASSWORD FOR wordpress@localhost= PASSWORD('wordpress');"
mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost IDENTIFIED BY 'wordpress';"
mysql -u root -e "FLUSH PRIVILEGES;"

source /etc/apache2/envvars
apache2 -D FOREGROUND
