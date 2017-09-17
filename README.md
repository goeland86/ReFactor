# Umikaze
Simplified Umikaze image generation, based on Ubuntu

The starting point for Umikaze is the Ubuntu console image, details are in the wiki here:
https://github.com/intelligent-agent/Umikaze/wiki

## Previous versions

The starting point for Kamikaze 2.0.0 is the Debian IoT image found here: 
https://debian.beagleboard.org/images/

For Kamikaze 1.0:  
    ssh root@kamikaze.local  
    cd /usr/src/  
    git clone http://github.org/eliasbakken/Kamikaze2  
    cd Kamikaze2  
    ./make-kamikaze-1.1.1.sh  

Here is how to recreate for Kamikaze 2.0:  
    ssh root@beaglebone.local  
    cd /usr/src/  
    git clone http://github.org/eliasbakken/Kamikaze2  
    cd Kamikaze2  
    ./make-kamikaze-2.0.0.sh  


The update command will kick the user out from the ssh session. 

# Changelog: 
2.1.1 - Support for BeagleBone Black Wireless! Fixed CPU governor to performance to guarantee full 1GHz clock speed at all times when printing. Included slic3r, upgraded to Octoprint 1.3.2, uses Redeem 2.0.0 tracking the staging branch to get updates sooner. Included PRU-software-support package to compile the new C PRU firmware from Redeem.

2.1.0 - Migrated from Debian IoT jessie base to Ubuntu 16.04.1LTS, using 4.1 LTS kernel, included 2 octoprint plugins (FileManager and Slicer) for nearly completely autonomous printer from the original setup. Switched from connman to Network-Manager, configuration done through console utility nmtui

2.0.0 - Kernel 4.4.20-bone13, cogl-1.22, clutter-1.26

1.1.1 - chown octo:octo on /etc/redeem and /etc/toggle

1.1.0 - Install latest Redeem, Toggle and OctoPrint from repositories. 


