#!/usr/bin/env bash

#set -x

SHOW_URI='http://hackerpublicradio.org/eps'
if [ -z "$HPR_FOLDER" ]; then
	HPR_FOLDER="/srv/audio/podcasts/hpr"
fi
if [ -z "$SYNC_FOLDER" ]; then
	SYNC_FOLDER="${HOME}/opt/mashpodder/new"
fi

# Calculate the latest show in the folder
LATEST=$( find "${HPR_FOLDER}/" -type f -name '*.ogg' | sort -r | head -n 1 )

if [ -z "$LATEST" ]; then
	echo "Error getting latest HPR episode!"
	exit 1
fi

# Start at the latest episode, and start counting down
LATEST_FILE=$( basename "$LATEST" )
SHOW_NUMBER="${LATEST_FILE:3:4}"

# Use temporary files to prevent partial episodes from being written
TEMP_SHOW_FILE=$( mktemp )
function cleanup_temp_file {
	if [ -e "$TEMP_SHOW_FILE" ]; then
		rm "$TEMP_SHOW_FILE"
	fi
}

trap "cleanup_temp_file" EXIT 

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

		if curl -L --limit-rate 50K -s "${SHOW_URI}/${SHOW_FILE}" > "$TEMP_SHOW_FILE"; then

			# If this is an old MP3 episode, remove the mp3
			if [ -e "$MP3_SHOW_FILE" ]; then
				rm "$MP3_SHOW_FILE" 
			fi

			mv "$TEMP_SHOW_FILE" "$SHOW_W_PATH"

			cp "$SHOW_W_PATH" "${SYNC_FOLDER}/${SHOW_FILE}"
		else
			echo "ERROR: Show download failed!"
			exit 404
		fi

		break
	fi

	let "SHOW_NUMBER=SHOW_NUMBER-1"
done

#set +x
