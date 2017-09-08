#!/bin/bash

echo "*** Stopping Octoprint ***"

systemctl stop octoprint

echo "*** Stopping Redeem ***"
systemctl stop redeem

echo "*** Stopping Toggle ***"
systemctl stop toggle

echo "*** Removing log files ***"

rm /home/octo/.octoprint/logs/*
touch /home/octo/.octoprint/logs/plugin_redeem.log
chown -R octo:octo /home/octo

echo "*** Removing bash history for root ***"
rm /root/.bash_history

echo "*** Removing bash history for ubuntu ***"
rm /home/ubuntu/.bash_history

echo "*** Removing bash history for octo ***"
rm /home/octo/.bash_history

poweroff
