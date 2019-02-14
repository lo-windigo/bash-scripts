#!/usr/bin/env bash

##
#
# RSYNC Backup Script - by Windigo ( https://fragdev.com )
#
#   Backup a directory, with built-in support for differential/incremental -
#   style backups by specifying a previous directory.
#
##

# Debug if anything other than empty
DEBUG=1
EXCLUDE=( 'cache/**' '__pycache__/**' '*.pyc' 'abcde.*' )

if [ ! $# -eq 2 ] && [ ! $# -eq 3 ]; then
	cat <<-USAGE
		Error: Unexpected number of arguments.

		Usage: $( basename $0 ) [previous backup] <source> <destination>"

		To see debugging information, you can set DEBUG=1, like so:

		DEBUG=1 $( basename $0 ) <args>

USAGE
	exit 1
fi

ARGS=("$@")

if [ ! -d "${ARGS[-2]}" ]; then
	echo "Invalid source directory: ${ARGS[-2]}"
	exit 2
fi

if [ ! -d "${ARGS[-1]}" ]; then
	echo "Invalid destination directory: ${ARGS[-1]}"
	exit 3
fi

# If a previous backup was provided, use it
if [ $# -eq 3 ]; then

	if [ ! -d "${ARGS[-3]}" ]; then
	  echo "Invalid link destination specified: ${ARGS[-3]}"
	  exit 4
	fi

	LINK_DEST="--link-dest=${ARGS[-3]}"
fi

# Ignore a few patterns
IGNORE=
if [ ! -z "$EXCLUDE" ]; then
	for PATTERN in "${EXCLUDE[@]}"; do
		IGNORE+="--exclude='${PATTERN}' "
	done
fi

# Provide a way to provide an ignore file
if [ -f "${ARGS[-2]}ignore.txt" ]; then
	IGNORE+="--exclude-from=${ARGS[-2]}ignore.txt"
fi


##
## Set up and execute rsync
##
#
# Available flags:
# a	- Archive mode; a whole lotta stuff happens with this flag
# S	- Handle sparse files efficiently
# n	- DRY RUN - DEBUG ONLY!
# fuzzy - Try to look for destination files that are missing (ie: moved)
# h	- Human readable numbers in output
# i	- Itemize changes; output a change summary
# v	- Verbose output
RSYNC_COMMAND='rsync --delete --partial -a -S '

if [ DEBUG ]; then
	RSYNC_COMMAND+='-h -i -v --progress '
fi

RSYNC_COMMAND+="$IGNORE $LINK_DEST ${ARGS[-2]} ${ARGS[-1]}"

echo 'Executing command in 5 seconds:'
echo "$RSYNC_COMMAND"
sleep 5s
eval $RSYNC_COMMAND
