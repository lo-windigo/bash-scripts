#!/usr/bin/env bash

if [ -z "$1" ]; then

	case "$( xclip -o | cut -d',' -f 1 )" in
		*png*)
			EXT='png'
			;;
		*jpg*)
			EXT='jpg'
			;;
		*gif*)
			EXT='gif'
			;;
		*)
			echo "Unknown image format."
			exit 404
	esac

	# Increment the number of files in the directory
	let "SEQUENTIAL=$( ls -1 | wc -l )+1"

	FILE="$( printf '%03d' $SEQUENTIAL ).${EXT}"

	if [ -e "$FILE" ]; then
		echo "File already exists!"
		exit 1
	fi
else
	FILE="$1"
fi

touch "${FILE}"

#DATA_URI=$( xclip -o )
#IMG_ARR=(${DATA_URI//,/ })

#echo "$DATA_URI" | head -c 40
#echo
#echo "${IMG_ARR[1]}" | head -c 40
#echo

xclip -o | cut -d',' -f 2 | base64 -d > $FILE

viewnior $FILE &> /dev/null &
