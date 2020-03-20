#!/usr/bin/env bash

SHOW_URI='http://hackerpublicradio.org/local'
if [ -z "$HPR_FOLDER" ]; then
	HPR_FOLDER="${HOME}/podcasts/hpr"
fi
if [ -z "$SYNC_FOLDER" ]; then
	SYNC_FOLDER="${HOME}/podcasts/sync"
fi

# Calculate the latest show in the folder
LATEST=$( \ls "${HPR_FOLDER}/"*.ogg | sort -r | head -n 1 )

if [ -z "$LATEST" ]; then
	echo "Error getting latest HPR episode!"
	exit 1
fi

# Start at the latest episode, and start counting down
LATEST_FILE=$( basename "$LATEST" )
SHOW_NUMBER="${LATEST_FILE:3:4}"

# Check to see, sequentially, which files exist
while [ "$SHOW_NUMBER" -gt 0 ]; do

	SHOW_FILE_NAME="hpr$( printf '%04d' $SHOW_NUMBER )"
	SHOW_FILE="${SHOW_FILE_NAME}.ogg"
	SHOW_W_PATH="${HPR_FOLDER}/${SHOW_FILE}"
	MP3_SHOW_FILE="${HPR_FOLDER}/${SHOW_FILE_NAME}.mp3"

	# We've found a show that we don't have yet - download it!
	if [ ! -e "$SHOW_W_PATH" ]; then

		if [ $DEBUG ]; then
			echo "Downloading ${SHOW_FILE}"
			sleep 6s
		fi

		if curl --limit-rate 50K -s "${SHOW_URI}/${SHOW_FILE}" > "$SHOW_W_PATH"; then

			# If this is an old MP3 episode, remove the mp3
			if [ -e "$MP3_SHOW_FILE" ]; then
				rm "$MP3_SHOW_FILE" 
			fi

			ln "$SHOW_W_PATH" "${SYNC_FOLDER}/${SHOW_FILE}"
		else
			echo "ERROR: Show download failed!"
			exit 404
		fi

		break
	fi

	let "SHOW_NUMBER=SHOW_NUMBER-1"
done

