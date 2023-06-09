#!/usr/bin/env bash
MAP_DIR=/var/minecrunch_backups/2023-06-02/world
CHECKS=(\
		"far_west" \
		"north_west" \
	)

# Args: int, int (ignored)
function far_west {
	if [ "$1" -lt -14 ]; then
		return 0
	fi

	return 1
}

# Args: int, int
function north_west {
	if [ "$1" -lt -10 ] && [ "$2" -lt 4 ]; then
		return 0
	fi

	return 1
}

# Args: filename
function needs_trim {

	# No empty filenames, please
	[ -z "$1" ] && return 1

	local REGION_FILE="$( basename "$1" )"

	R_NUM=( $( echo "$REGION_FILE" | cut -d. --output-delimiter=' ' -f2,3 ) )

	for CHECK in "${CHECKS[@]}"; do
		if "$CHECK" "${R_NUM[0]}" "${R_NUM[1]}"; then
			return 0
		fi
	done

	return 1
}

for REGION_DIR in "region" "entities"; do

	BACKUP_DIR="${MAP_DIR}/${REGION_DIR}_1.19_trim/"

	mkdir -p "$BACKUP_DIR"

	find "${MAP_DIR}/${REGION_DIR}/" -type f | \
		while read FILE; do

			if needs_trim "$FILE"; then
				echo -n "Trimming $FILE... "

				if mv "$FILE" "$BACKUP_DIR"; then
					echo 'successful'
				else
					echo 'failed'
				fi
			fi

		done
done
