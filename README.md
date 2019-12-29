# ReFactor
Simplified Thing-Printer board image generation toolset, based on Debian or Ubuntu images from RCN for beaglebone.

The starting point for ReFactor is the Ubuntu console image, details are in the wiki here:
https://github.com/intelligent-agent/ReFactor/wiki

ReFactor is a build-tool to install a printer's Firmware (at the moment Klipper), a printer control interface (OctoPrint or DWC), a touch-screen interface (Toggle w/ OctoPrint, DWC's tbd) and a few miscellaneous items (Cura 1.5, webcam streamer, network file share for gcode file uploads, etc.). 

It sets a default password for access as root on new images (root:kamikaze), but leaves the root account alone otherwise.
SSH is meant to be active and allow root login.

The images generated are focused on being a boot-strapped firmware for Thing-Printer control boards, such as Replicape and Recore. However PRs to make ReFactor an image generation tool for a wider range of single-board controllers is completely welcome. Ideally each board would have its own Ansible playbook at the root of the folder with a descriptive name, like
    replicape-klipper-octoprint-image.yml
    replicape-redeem-dwc-install.yml
The idea being that the image playbooks are run in a sandboxed environment and generate an image file ready to be flashed, while the install playbooks are meant to be executed on an already running debian-based controller.

## Previous versions

Umikaze 2.1.1 was built on Ubuntu 18.04.1 (LTS) and incorporated OctoPrint, Redeem and Toggle.
To learn more about Umikaze, go to https://github.com/intelligent-agent/Umikaze/wiki

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
2.2.0 - *** Work In Progress ***


2.1.1 - Support for BeagleBone Black Wireless! Fixed CPU governor to performance to guarantee full 1GHz clock speed at all times when printing. Included slic3r, upgraded to Octoprint 1.3.2, uses Redeem 2.0.0 tracking the staging branch to get updates sooner. Included PRU-software-support package to compile the new C PRU firmware from Redeem.

2.1.0 - Migrated from Debian IoT jessie base to Ubuntu 16.04.1LTS, using 4.1 LTS kernel, included 2 octoprint plugins (FileManager and Slicer) for nearly completely autonomous printer from the original setup. Switched from connman to Network-Manager, configuration done through console utility nmtui

2.0.0 - Kernel 4.4.20-bone13, cogl-1.22, clutter-1.26

1.1.1 - chown octo:octo on /etc/redeem and /etc/toggle

1.1.0 - Install latest Redeem, Toggle and OctoPrint from repositories. 


