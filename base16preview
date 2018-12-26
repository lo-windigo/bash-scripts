#!/usr/bin/env bash

B16_DIR=/home/windigo/.config/bash/colors/base16-shell
SCHEMES=( )

function b {
	echo -n '██████████'
}

for SCHEME in "${B16_DIR}/scripts/"*; do
	SCHEMES+=("$SCHEME")
done

if [ -z "$1" ]; then

	let "TEST_ROW = $( tput lines ) - 1"
	for SCHEME in "${!SCHEMES[@]}"; do

		SCHEME_NAME="$( basename ${SCHEMES[$SCHEME]} )"
		printf "%-26s  " "${SCHEME}: ${SCHEME_NAME:7:-3}"

		let "DIVISOR=${SCHEME}+1"
		if [ "$( expr $DIVISOR % 3)" -eq 0 ]; then
			echo
		fi

	done

	echo

else
	tput init

	SCHEME_INDEX="$1"

	if [ ! -e "${SCHEMES[$SCHEME_INDEX]}" ]; then
		echo 'Cannot find that particular scheme. Exiting'
		exit 1
	fi

	SCHEME="${SCHEMES[$SCHEME_INDEX]}"
	SCHEME_NAME="$( basename $SCHEME )"

	# load that scheme!
	source "$SCHEME"

	echo
	echo "${SCHEME_NAME:7:-3}:"
	echo
	echo 'Test Text'
	echo

	for ROW_NUM in $( seq 5 ); do
	 
		# Base16 colors are easiest to view in "BRIGHT" versions
		for COLOR_NUM in $( seq 8 16 ); do
			echo -n "$( tput sgr0 )$( tput setaf ${COLOR_NUM} )$( b )"
		done

		echo "$( tput sgr0 )"

	done

fi

