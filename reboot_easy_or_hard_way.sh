#!/usr/bin/env bash

if shutdown --reboot '+5m' 'The server will be shutting down in 5 minutes'; then
	# I gave you the chance of aiding me willingly...
	echo 'Restart successfully scheduled for five minutes from now.'
else
	# ...but you have elected the way of pain.
	echo 'Standard reboot has failed; attempting to force a reboot.'
	echo
	echo 'Manually sync disks...'
	echo s > /proc/sysrq-trigger
	echo 'Remount all filesystems in read-only mode...'
	echo u > /proc/sysrq-trigger
	echo 'Immediately reboot. Do not pass go, do not collect $200.'
	echo b > /proc/sysrq-trigger
	echo "If you're reading this, then we have bigger issues."
fi
