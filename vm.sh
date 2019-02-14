#!/usr/bin/env bash

DRIVE=( )
USBDRIVE=( )
INVOCATION="$( basename "$0" )"


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
#-net nic,type=virtio 
#-machine gfx_passthru=on \
#-machine none
read -r -d '' BASE_SYSTEM <<-'FIN'
-enable-kvm 
-m 4G 
-cpu host 
-smp 4 
-device nec-usb-xhci,id=xhci 
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
	stty intr ^]
	stty susp ^]
else
	read -r -d '' SYSTEM <<-'FIN'
	-boot menu=on
	-display sdl
	-soundhw ac97
	-usbdevice tablet
	-device virtio-keyboard-pci
	-device virtio-gpu-pci
	FIN
	# Old options:
	#-device usb-tablet
fi

# Fire up the machine that we've created
set -o xtrace
qemu-system-x86_64 $BASE_SYSTEM $SYSTEM ${USBDRIVE[@]} ${DRIVE[@]}


# Release the keys we stole for interrupt and suspend
if [ "$INVOCATION" == "vm-console" ]; then
	# TODO: Reset those keys, ya jerk
fi
