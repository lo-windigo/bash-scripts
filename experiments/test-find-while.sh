#!/usr/bin/env bash

DEST=/media/windigo/cbf2e6e4-f672-4a11-9d08-9694d2a3f528/atlas

while read DIR; do

	DIFFERENTIAL="$( newest $DEST )"
	CURRENT_BACKUP="$( basename "$DIR" )"

	# Roll our own rsync command, to prevent any nonsense
	RSYNC_COMMAND='rsync --delete --partial -a -S -h -i -v --progress '

	if [ ! -z "$DIFFERENTIAL" ]; then
		RSYNC_COMMAND+="--link-dest=${DIFFERENTIAL} "
	fi

	RSYNC_COMMAND+="${DIR}/* ${DEST}/${CURRENT_BACKUP}"

	echo 'Executing command in 5 seconds:'
	echo "$RSYNC_COMMAND"
	sleep 5s
	eval $RSYNC_COMMAND

done < <( find /data/backup/atlas/* -maxdepth 0 -type d | sort )
