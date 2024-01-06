#! /bin/bash

HOSTNAME="web"

# ---------- Change hostname ---------- #
sudo sh -c 'echo $HOSTNAME > /etc/hostname'
sudo hostname "$HOSTNAME"

# ---------- Install MySQL Client ---------- #
sudo apt update -y && sudo apt install git mysql-client -y
# mysql -h "<private-ip-of-db-server>" -u admin -padmin
sudo apt install python3 python3-pip -y