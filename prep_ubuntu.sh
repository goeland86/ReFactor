#!/bin/bash

export DEBIAN_FRONTEND=noninteractive 
echo "Installing ansible"
apt-get update
apt-get install -y ansible

echo "Now the system is ready to use the ansible playbooks to build images."
