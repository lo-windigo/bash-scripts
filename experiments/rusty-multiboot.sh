#!/bin/bash
if [ $# -lt 1 -o $# -ge 2 ]; then
 echo "Usage: $0 /dev/usb-drive LABEL" >&2
 exit 1
fi

if [ $(id -u) != 0 ]; then
 echo "Error: You must be root to run this script!" >&2
 exit 2
fi

TARGET="$1"
LABEL="$2"

[ -z "$LABEL" ] && LABEL=KANOTIX_USB

REM=$(cat /sys/block/${TARGET#/dev/}/removable 2>/dev/null)

if [ "$REM" != "1" ]; then
 echo "Error: No removeable drive $TARGET" >&2
 exit 4
fi

SFDISK=/sbin/sfdisk
MKDOSFS=/sbin/mkdosfs

TMP=$(mktemp -d /tmp/kanotix-usb.XXXXX)

dd if=/dev/zero of=$TARGET bs=1M count=100 conv=sync

$SFDISK -f -L -uS $TARGET <<EOT
2048,,b,*
EOT

$MKDOSFS -F32 -n "$LABEL" ${TARGET}1

mount ${TARGET}1 $TMP

grub-install --no-floppy --target=i386-pc --root-directory=$TMP $TARGET
grub-install --no-floppy --target=x86_64-efi --removable --root-directory=$TMP 
grub-install --no-floppy --target=i386-efi --removable --root-directory=$TMP
rm -vf $TMP/EFI/BOOT/grub.efi

wget -qO- http://kanotix.com/files/fix/kanotix-usb/boot.tar.gz|tar -vxzC $TMP

mkdir -p $TMP/ISO/KANOTIX
#cp -v kanotix32-kanotix-lxde-min-buster.iso $TMP/ISO/KANOTIX

umount $TMP
rmdir $TMP
