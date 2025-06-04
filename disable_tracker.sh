#!/usr/bin/env bash
#
# Disable the ridiculous Gnome tracker 3 processes
#
if [ "$(/usr/bin/id -u)" -eq 0 ]; then
	# Disable system components if running as root
	if systemctl --global status tracker-miner-fs-3.service > /dev/null; then
		dbus-launch systemctl --global disable tracker-miner-fs-3.service
	fi
else
	# Disable user components if running as a normal user
	if systemctl --user status tracker-miner-fs-3.service > /dev/null; then
		dbus-launch systemctl --user stop tracker-miner-fs-3.service
		dbus-launch systemctl --user mask tracker-miner-fs-3.service
	fi
fi

dbus-launch tracker3 reset -s -r > /dev/null

