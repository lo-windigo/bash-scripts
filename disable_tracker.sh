#!/usr/bin/env bash
#
# Disable the ridiculous Gnome tracker 3 processes
#

if [ "$(/usr/bin/id -u)" -eq 0 ]; then
	# Disable system components if running as root
	systemctl --global disable tracker-miner-fs-3.service

	tracker3 reset -s -r
else
	# Disable user components if running as a normal user
	systemctl --user stop tracker-miner-fs-3.service
	systemctl --user mask tracker-miner-fs-3.service

	tracker3 reset -s -r
fi

