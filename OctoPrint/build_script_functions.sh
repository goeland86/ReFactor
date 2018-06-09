for f in `ls versions.d/*`
  do
    source $f
  done

install_octoprint() {
	echo "** Install OctoPrint **"
	cd /home/octo
	if [ ! -d "OctoPrint" ]; then
		su - octo -c "git clone --no-single-branch --depth 1 $OCTOPRINT_REPOSITORY"
		su - octo -c "cd OctoPrint && git checkout tags/$OCTOPRINT_RELEASE"
	fi
	chown -R octo:octo /usr/local/lib/python2.7/dist-packages/
	chown -R octo:octo /usr/local/bin/
	su - octo -c "cd OctoPrint && python setup.py clean install"
	su - octo -c "pip install https://github.com/Salandora/OctoPrint-FileManager/archive/master.zip --user"
	su - octo -c "pip install https://github.com/kennethjiang/OctoPrint-Slicer/archive/master.zip --user"

	cd $WD
	# Make config file for Octoprint
	cp OctoPrint/config.yaml /home/octo/.octoprint/
	chown  -R octo:octo "/home/octo/"

	# Fix permissions for STL upload folder
	mkdir -p /usr/share/models
	chown octo:octo /usr/share/models
	chmod 777 /usr/share/models

	# Grant octo redeem restart rights
	echo "%octo ALL=NOPASSWD: /bin/systemctl restart redeem.service" >> /etc/sudoers
	echo "%octo ALL=NOPASSWD: /bin/systemctl restart toggle.service" >> /etc/sudoers
	echo "%octo ALL=NOPASSWD: /bin/systemctl restart mjpg.service" >> /etc/sudoers
	echo "%octo ALL=NOPASSWD: /bin/systemctl restart octoprint.service" >> /etc/sudoers
	echo "%octo ALL=NOPASSWD: /sbin/reboot" >> /etc/sudoers
	echo "%octo ALL=NOPASSWD: /sbin/shutdown -h now" >> /etc/sudoers
	echo "%octo ALL=NOPASSWD: /sbin/poweroff" >> /etc/sudoers

	echo "%octo ALL=NOPASSWD: /usr/bin/make -C /usr/local/src/redeem install" >> /etc/sudoers
	echo "%octo ALL=NOPASSWD: /usr/bin/make -C /usr/src/toggle install" >> /etc/sudoers

	# Install systemd script
	cp ./OctoPrint/octoprint.service /lib/systemd/system/
	sed -i "s/KAMIKAZE/$VERSION/" /home/octo/.octoprint/config.yaml
	systemctl enable octoprint
	systemctl start octoprint
}
