#!/usr/bin/env bash

# Format for the "currently playing" line
FMT='General;%Title%, by %Artist% on %Album%'
OLD_IFS="$IFS"
IFS=$'\n'
MUSIC_DIR=~/Music

## Ctrl+C should quit
trap 'exit' SIGINT

if [ ! -z "$1" ]; then
	MUSIC_DIR="$1"
fi

# Fix the internal field separator before we go
function fix_ifs {
	IFS="$OLD_IFS"
}

trap 'fix_ifs' EXIT

find "$MUSIC_DIR" -type f \( -iname '*.ogg' -o -iname '*.flac' -o -iname '*.mp3' \
	-o -iname '*.wma' \) | head -n 1000 | sort -R | \
	while read CURRENTLY_PLAYING; do
	mediainfo --Inform="$FMT" "$CURRENTLY_PLAYING"
	echo "$CURRENTLY_PLAYING"
	mpv --no-video --msg-level=all=no,statusline=status,term-msg=status \
		"$CURRENTLY_PLAYING"
	echo 
done

