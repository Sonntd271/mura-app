#! /bin/bash

HOSTNAME="mysql"

# ---------- Change hostname ---------- #
sudo sh -c 'echo $HOSTNAME > /etc/hostname'
sudo hostname "$HOSTNAME"

# ---------- Install MySQL ---------- #
sudo apt update -y && sudo apt install mysql-server -y
# Replace bind-address in conf file
sudo sed -i -E 's/^bind-address\t\t= 127.0.0.1/bind-address\t\t= 0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
# Create a remote user
sudo mysql -u root < /tmp/db-setup.sql
sudo systemctl restart mysql
sudo systemctl enable mysql
