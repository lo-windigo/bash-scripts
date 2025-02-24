#!/usr/bin/env bash

CONSOLE_CMD='vm_console'
DRIVE=( )
USBDRIVE=( )
INVOCATION="$( basename "$0" )"
SYS_RAM="$( cat /proc/meminfo | grep MemTotal | xargs | cut -d' ' -f 2 )"
SYS_CPU="x86_64"

let 'VM_RAM=SYS_RAM / 2048'

if [ -z "$1" ] || [ "$1" == '-h' ]; then
	if [ "$INVOCATION" == "$CONSOLE_CMD" ]; then
		DESC='Launch a QEMU/KVM text-based virtual machine'
	else
		DESC='Launch a QEMU/KVM graphical virtual machine'
	fi

	echo
	echo "${INVOCATION} - ${DESC}"
	echo
	echo '-h   Usage / help'
	echo '-arm ARM VM'
	echo '-c   CD ROM image/device'
	echo '-d   Disk image (raw format)'
	echo '-u   USB drive image'
	exit
fi
	

# Assign anyd drives sent in
while [ $# -ge 2 ]; do

	ARGS_TO_SHIFT=2

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
	# ARM emulation
	elif [ $1 == '-arm' ]; then
		SYS_CPU='arm -machine musicpal'
		ARGS_TO_SHIFT=1
	else
		echo "Unrecognized option: '${1}'"
		exit 1
	fi

	# Skip to the next two arguments
	shift $ARGS_TO_SHIFT 
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
-smp 4
-nic user
-device nec-usb-xhci,id=xhci 
-object rng-random,id=rng0,filename=/dev/urandom
-device virtio-rng-pci,rng=rng0
FIN

# Decide which kind of machine we want
if [ "$INVOCATION" == "$CONSOLE_CMD" ]; then

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
	#VM_SPICE_SOCKET=$( mktemp -t vm_XXXXXX.spice )

	read -r -d '' SYSTEM <<-FIN
	-boot menu=on
	-device intel-hda
	-device hda-duplex
	-device usb-tablet
	-device virtio-keyboard-pci
	-display gtk,gl=off
	-vga virtio
	FIN
	#-device virtio-gpu-pci
	#-device AC97
	#-display gtk,gl=on  # Terrible performance?
	#-vga std # Debian
	#-vga virtio
	#-display gtk # Debian
	#-display sdl,gl=on # Terrible performance
	#-display sdl
	#-spice addr=$VM_SPICE_SOCKET,disable-ticketing=on,unix=on # Ubuntu: good
	#performance, no boot display
	#--soundhw hda # Deprecated
fi

# Fire up the machine that we've created
set -o xtrace
if [ "$INVOCATION" == "$CONSOLE_CMD" ]; then
	qemu-system-$SYS_CPU $BASE_SYSTEM $SYSTEM ${USBDRIVE[@]} ${DRIVE[@]}
else
	qemu-system-$SYS_CPU $BASE_SYSTEM $SYSTEM ${USBDRIVE[@]} ${DRIVE[@]}
	#set +o xtrace

	#VM_PID=$!

	#echo 'Connecting to spice server with spicy...'
	#sleep 2s
	#spicy --uri="spice+unix://$VM_SPICE_SOCKET"
fi

if [ -e "$VM_SPICE_SOCKET" ]; then
	rm "$VM_SPICE_SOCKET"
fi

# Release the keys we stole for interrupt and suspend
if [ "$INVOCATION" == "$CONSOLE_CMD" ]; then
	stty "$STTY_SETTINGS"
fi
