#!/bin/bash

export DEBIAN_FRONTEND=noninteractive 
echo "Installing ansible"

echo "deb http://deb.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

apt-get update
apt-get -t stretch-backports install -y ansible git python-pip python3-pip python-virtualenv python3-venv

echo "debian	ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "Now the system is ready to use the ansible playbooks to build images."
