#!/bin/bash
set -x
set -e

wget https://rcn-ee.com/rootfs/2017-05-21/microsd/bone-ubuntu-16.04.2-console-armhf-2017-05-21-2gb.img.xz

xz -T 0 -d bone-ubuntu-16.04.2-console-armhf-2017-05-21-2gb.img.xz
dd if=/dev/zero bs=1M count=2048 >> bone-ubuntu-16.04.2-console-armhf-2017-05-21-2gb.img
DEVICE=`losetup -P -f --show bone-ubuntu-16.04.2-console-armhf-2017-05-21-2gb.img`

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

mount ${DEVICE}p1 /mnt/root
mount -o bind /dev /mnt/root/dev
mount -o bind /sys /mnt/root/sys
mount -o bind /proc /mnt/root/proc

mkdir -p /mnt/root/run/resolvconf
cp /etc/resolv.conf /mnt/root/run/resolvconf/resolv.conf

cp make-kamikaze-2.1.sh /mnt/root/root
cp prep_ubuntu.sh /mnt/root/root
git clone https://github.com/goeland86/Umikaze2.git /mnt/root/usr/src/Umikaze2
chroot /mnt/root /bin/su -c "cd /root && ./prep_ubuntu.sh && ./make-kamikaze-2.1.sh"

umount /mnt/root/proc
umount /mnt/root/sys
umount /mnt/root/dev
umount /mnt/root

./generate-image-from-sd.sh $DEVICE

losetup -d $DEVICE
