#!/usr/bin/env bash

set -e

# Cleanup some information, that shouldn't be persisted in the image

sudo bash <<"SCRIPT"
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/ssh/ssh_host_*

# truncate (but not delete) certain files
find /var/log -type f -print0 | xargs -0r truncate -s0

# remove packer's public key
sed -n '/^ssh-rsa.*packer_.*/d' /home/ubuntu/.ssh/authorized_keys
SCRIPT
