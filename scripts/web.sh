#! /bin/bash

sudo apt update -y && sudo apt install mysql-client -y
mysql -h "<private-ip-of-db-server>" -u admin -padmin
