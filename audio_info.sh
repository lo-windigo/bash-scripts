#!/usr/bin/env bash
while read FILE; do
	echo "$FILE"
	ogginfo "$FILE" | grep '\(TITLE\|TRACKNUMBER\|Playback length\)'
	echo "- - - - - - - -"
done < <(find . -type f -name "$1"'*')
