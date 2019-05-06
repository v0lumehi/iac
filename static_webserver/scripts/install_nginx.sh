#!/usr/bin/env bash

# Do installation of nginx here
sudo bash -e <<SCRIPT
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

mv /tmp/index.html /var/www/html/

chmod 655 /var/www/html/index.html

systemctl restart nginx
SCRIPT
