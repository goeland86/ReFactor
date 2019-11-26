#!/bin/bash

export DEBIAN_FRONTEND=noninteractive 
echo "Installing ansible"
apt-get update
apt-get install ansible
echo "executing Ansible playbook for linux_preparation"
ansible-playbook prep-ubuntu.yml

echo "Now reboot into the new kernel and run make-kamikaze.sh"
