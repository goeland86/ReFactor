#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
echo "Installing ansible"

apt-get -y remove apache2
apt-get -y autoremove
apt-get update
apt-get -y install ansible git python3-pip python3-venv python-pip python-virtualenv python-apt python3-apt

echo "Now the system is ready to use the ansible playbooks to build images."
