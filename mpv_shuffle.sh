#!/usr/bin/env bash

# Ensure a non-image random song
function random_song {
	local CURRENTLY_PLAYING

	while [ -z "$CURRENTLY_PLAYING" ]; do
		CURRENTLY_PLAYING="$( random_file ~/Music )"

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

while true; do
	CURRENTLY_PLAYING="$( random_song )"

	mpv --no-video --msg-level=all=no,statusline=status,term-msg=status \
		--term-playing-msg='Currently Playing: ${media-title:Unknown} (${filename})' \
		"$CURRENTLY_PLAYING"
	echo 
	sleep .5s
done

