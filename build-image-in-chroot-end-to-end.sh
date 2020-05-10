#!/bin/bash

if [ "$#" -lt 1 ]; then
	echo "We need to know which platform we're building for."
	echo "Should be one of: {replicape, recore, raspihf, raspi64}"
	echo "Usage: build-image-in-chroot-end-to-end.sh platform [system-build-script]"
	exit
fi

if [ "$#" -eq 2 ]; then
	SYSTEM_ANSIBLE=$2
else
	SYSTEM_ANSIBLE=SYSTEM_klipper_octoprint-DEFAULT.yml
fi

if [ ! -f ${SYSTEM_ANSIBLE} ]; then
	echo "Could not find the system build playbook ${SYSTEM_ANSIBLE}. Cannot continue."
	exit
fi

set -x
set -e


TARGET_PLATFORM=$1

for f in $(ls BaseLinux/${TARGET_PLATFORM}/*)
  do
    source $f
  done
if [ -f "customize.sh" ] ; then
  source customize.sh
fi

TARGETIMAGE=refactor-${TARGET_PLATFORM}-rootfs.img
MOUNTPOINT=$(mktemp -d /tmp/umikaze-root.XXXXXX)
REFACTOR_HOME="/usr/src/ReFactor"

if [ ! -f $BASEIMAGE ]; then
    wget $BASEIMAGE_URL -O $BASEIMAGE
fi

rm -f $TARGETIMAGE
decompress || $(echo "check your Linux platform file is correct!"; exit) # defined in the BaseLinux/{platform}/Linux file
#if [ $TARGET_PLATFORM == 'replicape' ]; then
truncate -s 4G $TARGETIMAGE
#fi

DEVICE=`losetup -P -f --show $TARGETIMAGE`

cat << EOF | fdisk ${DEVICE}
p
d
n
p
1
8192

p
w

EOF

e2fsck -f ${DEVICE}p1
resize2fs ${DEVICE}p1

mount ${DEVICE}p1 ${MOUNTPOINT}
mount -o bind /dev ${MOUNTPOINT}/dev
mount -o bind /sys ${MOUNTPOINT}/sys
mount -o bind /proc ${MOUNTPOINT}/proc

rm ${MOUNTPOINT}/etc/resolv.conf
cp /etc/resolv.conf ${MOUNTPOINT}/etc/resolv.conf

# don't git clone here - if someone did a commit since this script started, Unexpected Things will happen
# instead, do a deep copy so the image has a git repo as well
mkdir -p ${MOUNTPOINT}${REFACTOR_HOME}

shopt -s dotglob # include hidden files/directories so we get .git
shopt -s extglob # allow excluding so we can hide the img files
cp -r `pwd`/!(*.img*) ${MOUNTPOINT}${REFACTOR_HOME}
shopt -u extglob
shopt -u dotglob

if [ -f "customize.sh" ]; then
  add_custom_account
  perform_minimal_reconfiguration
fi

set +e # allow this to fail - we'll check the return code
cat << EOF | chroot ${MOUNTPOINT} su -c passwd
1234
kamikaze
kamikaze
EOF

chroot ${MOUNTPOINT} su -c "cd ${REFACTOR_HOME} && ./prep_apt.sh && ansible-playbook ${SYSTEM_ANSIBLE} -T 180 --extra-vars '${ANSIBLE_PLATFORM_VARS}'"

status=$?
set -e

rm ${MOUNTPOINT}/etc/resolv.conf
umount ${MOUNTPOINT}/proc
umount ${MOUNTPOINT}/sys
umount ${MOUNTPOINT}/dev
umount ${MOUNTPOINT}
rmdir ${MOUNTPOINT}

if [ $status -eq 0 ]; then
    echo "Looks like the image was prepared successfully - packing it up"
    ./update-u-boot.sh $DEVICE
    ./generate-image-from-sd.sh $DEVICE
else
    echo "image generation seems to have failed - cleaning up"
fi



losetup -d $DEVICE
