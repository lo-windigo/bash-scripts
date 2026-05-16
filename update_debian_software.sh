#!/usr/bin/env bash

function exists {
	which "$1" > /dev/null
}

function update_debs {
	
	if ! exists apt; then
		echo 'Skipping debian packages; unable to find apt.'
		return 1
	fi

	sudo apt update
	sudo apt upgrade
	sudo apt autoclean

	echo 'Debian packages updated'
}

function update_flatpak {
	if ! exists flatpak; then
		echo 'Skipping flatpak packages; unable to find flatpak.'
		return 1
	fi

	flatpak update
	flatpak uninstall --unused

	echo 'Flatpak apps updated'
}

function update_snap {
	if ! exists snap; then
		echo 'Skipping snap packages; unable to find snap.'
		return 1
	fi

	sudo snap refresh

	echo 'Snap packages updated'
}


### Update all possible package types
update_debs
update_flatpak
update_snap
