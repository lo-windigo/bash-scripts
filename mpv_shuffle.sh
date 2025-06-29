#!/usr/bin/env bash

# Configurations
MUSIC_DIR="$HOME/Music"
NUM_SONGS=1000

# Allow user to override the music directory
if [ ! -z "$1" ]; then
	MUSIC_DIR="$1"
fi

# Switch the internal field separator, and fix when we exit
OLD_IFS="$IFS"
IFS=$'\n'
function fix_ifs {
	IFS="$OLD_IFS"
}
trap 'fix_ifs' EXIT

# Function to generate a M3U playlist of NUM_SONGS random songs
function playlist {
	find "$MUSIC_DIR" -type f -iregex '.*.\(ogg\|flac\|mp3\|oga\|\wma\)' \
		| sort -R \
		| tail -n $NUM_SONGS
}

#--msg-level=all=info,statusline=status,term-msg=status \
mpv --no-video --playlist=<( playlist )

