#! /bin/bash

sudo apt update -y && sudo apt install memcached -y
sudo systemctl start memcached
sudo systemctl enable memcached