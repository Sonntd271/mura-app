#! /bin/bash

sudo apt update -y && sudo apt install memcached -y
sudo sed -i -E 's/^-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf # Listen on remote interfaces
sudo systemctl restart memcached
sudo systemctl enable memcached
