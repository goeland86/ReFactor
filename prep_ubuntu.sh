#!/bin/bash
set -x
>/root/prep_ubuntu.log
exec >  >(tee -ia /root/prep_ubuntu.log)
exec 2> >(tee -ia /root/prep_ubuntu.log >&2)

WD=/usr/src/Umikaze2/

network_fixes() {
	echo "Fixing network interface config..."
	sed -i 's/After=network.target auditd.service/After=auditd.service/' /etc/systemd/system/multi-user.target.wants/ssh.service
}

prep_ubuntu() {
	echo "Upgrading packages"
	apt-get update
	echo "** Preparing Ubuntu for kamikaze2 **"
	cd /opt/scripts/tools/
	git pull
	sh update_kernel.sh --lts-4_4
	apt-get -y upgrade
	apt-get -y --no-install-recommends install unzip iptables
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

network_fixes() {
	echo "** Disable wireless power management **"
	mkdir -p /etc/pm/sleep.d
	touch /etc/pm/sleep.d/wireless

	echo "** Install Network Manager **"
	apt-get -y install --no-install-recommends network-manager
	ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
	sed -i 's/^\[main\]/\[main\]\ndhcp=internal/' /etc/NetworkManager/NetworkManager.conf
	cp $WD/interfaces /etc/network/

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
	network_fixes
	prep_ubuntu
	install_repo
	network_fixes
	remove_unneeded_packages
	cleanup
}

prep

echo "Now reboot into the new kernel and run make-kamikaze-2.1.sh"
