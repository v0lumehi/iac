#!/usr/bin/env bash

# Do installation of nodejs and the nodejs app here
sudo bash -e <<SCRIPT
apt-get install -y curl
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
apt-get install -y nodejs
mkdir /home/ubuntu/sample-node-app/
git clone https://github.com/mbeham/nodejs-demo-app.git /home/ubuntu/sample-node-app/
chown -R ubuntu:ubuntu /home/ubuntu/sample-node-app/
cd /home/ubuntu/sample-node-app/
npm install
cp /home/ubuntu/sample-node-app/contrib/hello.service /etc/systemd/system/
systemctl enable hello.service
SCRIPT
