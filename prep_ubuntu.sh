#!/bin/bash
set -x
set -e
>/root/prep_ubuntu.log
exec >  >(tee -ia /root/prep_ubuntu.log)
exec 2> >(tee -ia /root/prep_ubuntu.log >&2)

WD=/usr/src/Umikaze/

prep_ubuntu() {
	echo "Upgrading packages"
	apt-get update
	echo "Removing unwanted kernel packages"
#	apt-get -y remove linux-image-*
	apt-get -y autoremove
#	systemctl disable bb-wl18xx-wlan0
	echo "Updating uboot..."
	sed -i 's\uboot_overlay_pru=/lib/firmware/AM335X-PRU-RPROC\#uboot_overlay_pru=/lib/firmware/AM335X-PRU-RPROC\' /boot/uEnv.txt
	sed -i 's\#uboot_overlay_pru=/lib/firmware/AM335X-PRU-UIO\uboot_overlay_pru=/lib/firmware/AM335X-PRU-UIO\' /boot/uEnv.txt
	echo "** Preparing Ubuntu for kamikaze2 **"

	cd /opt/scripts/tools/
	git pull
	sh update_kernel.sh --lts-4_14 --ti-kernel # this is what will update to the latest bone kernel with initrd!
	KERNEL_VERSION=`cat /boot/uEnv.txt | grep uname_r | awk -F '=' '{print $2}'`
	apt-get install linux-headers-$KERNEL_VERSION
	# apt-get -y install ti-sgx-es8-modules-$KERNEL_VERSION
	depmod $KERNEL_VERSION
	update-initramfs -k $KERNEL_VERSION -u
	
	cd /usr/src/
	git clone git://git.ti.com/wilink8-wlan/wl18xx_fw.git
	cp /usr/src/wl18xx_fw/wl18xx-fw-4.bin /lib/firmware/ti-connectivity/wl18xx-fw-4.bin

	apt-get -y upgrade
	apt-get -y -q --no-install-recommends --force-yes install unzip iptables iptables-persistent
	systemctl enable netfilter-persistent
	sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
}

install_repo() {
	echo "installing Kamikaze repo to the list"
	cat >/etc/apt/sources.list.d/testing.list <<EOL
#### Kamikaze ####
deb [arch=armhf] http://kamikaze.thing-printer.com/ubuntu/ xenial main
#deb [arch=armhf] http://kamikaze.thing-printer.com/debian/ stretch main
EOL
	wget -q http://kamikaze.thing-printer.com/ubuntu/public.gpg -O- | apt-key add -
#	wget -q http://kamikaze.thing-printer.com/debian/public.gpg -O- | apt-key add -
	apt-get update
}

network_manager() {
	echo "** Disable wireless power management **"
	mkdir -p /etc/pm/sleep.d
	touch /etc/pm/sleep.d/wireless

	echo "** Install Network Manager **"
	apt-get -y install --no-install-recommends network-manager
	#ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
	sed -i 's/^\[main\]/\[main\]\ndhcp=internal/' /etc/NetworkManager/NetworkManager.conf
}

remove_unneeded_packages() {
	echo "** Remove unneded packages **"*
	rm -rf /etc/apache2/sites-enabled
	rm -rf /root/.c9
	rm -rf /usr/local/lib/node_modules
	rm -rf /var/lib/cloud9
	rm -rf /usr/lib/node_modules/
	apt-get purge -y apache2 apache2-bin apache2-data apache2-utils hostapd
}

cleanup() {
	apt-get remove -y libgtk-3-common
	apt-get autoremove -y
}

prep() {
	prep_ubuntu
	install_repo
	network_manager
	remove_unneeded_packages
	cleanup
}

prep

echo "Now reboot into the new kernel and run make-kamikaze-2.1.sh"
