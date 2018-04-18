#!/bin/bash

#############################################################
# This builds Umikaze 2.1.2 from the 2.1.1 base image only. #
# Execute it as root from a 2.1.1 image booting from SD.    #
#############################################################

OCTO_RELEASE=1.3.8
REDEEM_RELEASE=2.1.2

WD=/usr/src/

# fix kernel package in place:
apt-mark hold linux-image-4.4.69-bone17

# update various packages to be installed
apt-get update
apt-get -y upgrade
pip install --upgrade pip

# remove the source for Redeem, Toggle and OctoPrint to get the latest versions
rm -r /usr/src/redeem\
      /usr/src/toggle\
      /home/octo/OctoPrint\
      /usr/local/redeem\
      /usr/local/lib/python2.7/dist-packages/Redeem*\
      /usr/local/lib/python2.7/dist-packages/redeem\
      /usr/local/lib/python2.7/dist-packages/_Path*

# fetch the wanted version of Redeem
cd $WD
git clone --depth 1 --no-single-branch https://github.com/intelligent-agent/redeem.git
cd redeem
git checkout tags/$REDEEM_RELEASE
make install
chown -R octo:octo /etc/redeem/

# fetch the wanted version of Toggle
cd $WD
git clone --depth 1 --no-single-branch https://github.com/intelligent-agent/toggle.git
cd toggle
make install
chown -R octo:octo /etc/toggle

# fetch the wanted version of OctoPrint
cd /home/octo/
git clone --depth 1 --no-single-branch https://github.com/foosel/OctoPrint
cd OctoPrint
git checkout tags/$OCTO_RELEASE
python setup.py install
cd /home/octo/
chown -R octo:octo OctoPrint .octoprint

# reset root password to the default and force change on first login:
chage -d 0 root
echo "root:kamikaze" | chpasswd

# remove the ubuntu user to prevent another security leak:
deluser ubuntu

# fetch the updated version of mjpg-streamer for newer and better video streaming
cd $WD
rm -r mjpg-streamer
git clone --no-single-branch --depth 1 https://github.com/jacksonliam/mjpg-streamer
cd mjpg-streamer
make
make install

# update the functions.sh from the Umikaze2 repo:
cd $WD/Umikaze
git reset --hard
git pull
cp functions.sh /opt/scripts/tools/eMMC/functions.sh

# aaaand we're done.
echo "Ok, 2.1.2 is built. Now remember to uncomment the flasher from /boot/uEnv.txt, and you're good to go!"
