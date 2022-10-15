#!/usr/bin/env bash

DRIVE=( )
USBDRIVE=( )
INVOCATION="$( basename "$0" )"
SYS_RAM="$( cat /proc/meminfo | grep MemTotal | xargs | cut -d' ' -f 2 )"
let 'VM_RAM=SYS_RAM / 2048'

if [ -z "$1" ] || [ "$1" == '-h' ]; then
	if [ "$INVOCATION" == "vm-console" ]; then
		DESC='Launch a QEMU/KVM text-based virtual machine'
	else
		DESC='Launch a QEMU/KVM graphical virtual machine'
	fi

	echo
	echo "${INVOCATION} - ${DESC}"
	echo
	echo '-h  Usage / help'
	echo '-c  CD ROM image/device'
	echo '-d  Disk image (raw format)'
	echo '-u  USB drive image'
	exit
fi
	

# Assign anyd drives sent in
while [ $# -ge 2 ]; do

	# CD images
	if [ $1 == '-c' ]; then
		DRIVE+=("-cdrom ${2}")
	# Disk drives
	elif [ $1 == '-d' ]; then
		DRIVE+=("-drive file=${2},format=raw")
	# USB disk drives
	elif [ $1 == '-u' ]; then
		#DRIVE+=("-usbdevice disk:format=raw:${2}")
		DRIVEID="usbdisk${#USBDRIVE[@]}"
		USBDRIVE+=("-drive if=none,id=${DRIVEID},format=raw,file=${2} -device usb-storage,drive=${DRIVEID}")
	else
		echo "Unrecognized option: '${1}'"
		exit 1
	fi

	# Skip to the next two arguments
	shift 2
done

# Set up the base system details
#
#-machine gfx_passthru=on \
#-machine none
#-netdev tap,id=nd0,ifname=tap0
#-net user
read -r -d '' BASE_SYSTEM <<-FIN
-enable-kvm 
-m ${VM_RAM}M 
-cpu host 
-nic user
-device nec-usb-xhci,id=xhci 
-object rng-random,id=rng0,filename=/dev/urandom
-device virtio-rng-pci,rng=rng0
FIN

# Decide which kind of machine we want
if [ "$INVOCATION" == "vm-console" ]; then

	# Set options for a console-only virtual machine, using the host terminal
	read -r -d '' SYSTEM <<-'FIN'
	-nographic
	-monitor none
	-serial stdio
	FIN

	# Override Ctrl+c and Ctrl+z to prevent killing the VM in horrid ways
	STTY_SETTINGS="$( stty -g )"
	stty intr ^]
	stty susp ^]
else
	read -r -d '' SYSTEM <<-'FIN'
	-boot menu=on
	-display gtk
	-vga virtio
	-device AC97
	-device usb-tablet
	-device virtio-keyboard-pci
	-device virtio-gpu-pci
	FIN
	#-display sdl
	#-vga virtio
	#-vga std
fi

# Fire up the machine that we've created
set -o xtrace
qemu-system-x86_64 $BASE_SYSTEM $SYSTEM ${USBDRIVE[@]} ${DRIVE[@]}


# Release the keys we stole for interrupt and suspend
if [ "$INVOCATION" == "vm-console" ]; then
	stty "$STTY_SETTINGS"
fi
