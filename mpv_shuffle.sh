#!/usr/bin/env bash

# Format for the "currently playing" line
FMT='General;%Title%, by %Artist% on %Album%'
OLD_IFS="$IFS"
IFS=$'\n'
MUSIC_DIR=~/Music

if [ ! -z "$1" ]; then
	MUSIC_DIR="$1"
fi

function fix_ifs {
	IFS="$OLD_IFS"
}

# Ensure a non-image random song
function random_song {
	local CURRENTLY_PLAYING

	while [ -z "$CURRENTLY_PLAYING" ]; do
		CURRENTLY_PLAYING="$( random_file "$MUSIC_DIR" )"

		case $CURRENTLY_PLAYING in
			*.ogg|*.flac|*.mp3|*.wma)
				# File is in accepted types - do not reset CURRENTLY_PLAYING
				;;
			*)
				# Unrecognized file type - skip
				CURRENTLY_PLAYING=
				;;
		esac
	done

	echo $CURRENTLY_PLAYING	
}

trap fix_ifs EXIT

while true; do
	CURRENTLY_PLAYING="$( random_song )"

	mediainfo --Inform="$FMT" "$CURRENTLY_PLAYING"
	echo "$CURRENTLY_PLAYING"
	mpv --no-video --msg-level=all=no,statusline=status,term-msg=status \
		"$CURRENTLY_PLAYING"
	echo 
	sleep .1s
done

