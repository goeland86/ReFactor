for f in `ls versions.d/*`
  do
    source $f
  done

install_redeem() {
  echo "**install_redeem**"
  cd /usr/local/src/
  if [ ! -d "redeem" ]; then
    git clone --no-single-branch --depth 1 $REDEEM_REPOSITORY
  fi
  cd redeem
  git pull
  git checkout $REDEEM_BRANCH
  make install

  # Make profiles uploadable via Octoprint
  cp -r configs /etc/redeem
  cp -r data /etc/redeem
  touch /etc/redeem/local.cfg
  chown -R octo:octo /etc/redeem/
  chown -R octo:octo /usr/local/src/redeem/

  cd $WD

  # Install rules
  cp scripts/spidev.rules /etc/udev/rules.d/

  # Install Umikaze2 specific systemd script
  cp scripts/redeem.service /lib/systemd/system
  systemctl enable redeem
  # systemctl start redeem
}
