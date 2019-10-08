#!/usr/bin/env bash

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#                                                 #
# Backup Atlas                                    #
#                                                 #
# Incrementally back up directories on the server #
#                                                 #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# Runtime configurations
# Feel free to override with environment variables
DEBUG="${DEBUG:-1}"
SUMMARY="${SUMMARY:-1}"
BACKUP_SOURCES="${BACKUP_SOURCES:-/etc/backup-sources.d}"



# WARNING:
#
# Changes below this line may void your warranty or
# improve my scripts. You have been warned?

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Run the rsync command for each directory        #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function backup_directories {
	for THIS_DIR in ${SOURCE_DIRS[@]}; do

		# Start creating a rsync command to back up this directory
		local THIS_DIR_RSYNC="${RSYNC_COMMAND} ${SOURCE_SERVER}:${THIS_DIR} ${THIS_BACKUP}"

		debug '--------------------------------------------------'
		[ $SUMMARY ] && echo "> ${THIS_DIR}"
		debug 'Running "'${THIS_DIR_RSYNC}'" in 5 seconds...'
		[ $DEBUG ] && sleep 5s

		eval ${THIS_DIR_RSYNC}
	done
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Reset all variables to an empty state           #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function clear_variables {
	SOURCE_SERVER=
	SOURCE_DIRS=
	DEST_DIR=
	IGNORE_LIST=
	EXCLUDE=
	NUM_BACKUPS=
	CURRENT_BACKUP=
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Print output, if debug flag is specified        # 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function debug {

	# If we are not debugging, return non-zero
	# (allow chaining debugging commands)
	[ ! $DEBUG ] && return 1

	# If arguments are supplied, print them to
	# stdErr - otherwise exit with successful
	# return code
    [ ! -z "$@" ] && echo "$@" 1>&2
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Get the newest directory in a directory         # 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function newest {
	if [ ! -d "${1}" ]; then
		debug "Invalid directory specified"
		return 10
	fi

	local DIRECTORY="$( dirname "$1" )/$( basename "$1" )"
	find "$DIRECTORY"/* -maxdepth 0 -type d | sort -r | head -n 1 
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Get the oldest directory in a directory         #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function oldest {
	if [ ! -d "${1}" ]; then
		debug "Invalid directory specified"
		return 10
	fi

	local DIRECTORY="$( dirname "$1" )/$( basename "$1" )"
	find "$DIRECTORY"/* -maxdepth 0 -type d | sort | head -n 1 
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Remove previous backups                         #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function remove_old_backups {

	local TOTAL_DIR_COUNT=$( find "${DEST_DIR}/"* -maxdepth 0 -type d | wc -l )
	let NUM_BACKUPS_TO_DELETE=TOTAL_DIR_COUNT-KEEP_NUMBER

	while [ "${NUM_BACKUPS_TO_DELETE}" -gt 0 ]; do
		local OLDEST_BACKUP="$( oldest "${DEST_DIR}" )"
		if [ -d "${OLDEST_BACKUP}" ]; then
			debug "Deleting old backup at ${OLDEST_BACKUP}..."
			[ $DEBUG ] && sleep 15s
			rm -rf "${OLDEST_BACKUP}"
			debug "...done."
		fi
		let NUM_BACKUPS_TO_DELETE=NUM_BACKUPS_TO_DELETE-1
	done
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Do the backin' up, for Pete's sake.             #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function run_backup {

	### Set up the rsync command
	# Available flags:
	# a	- Archive mode; a whole lotta stuff happens with this flag
	# S	- Handle sparse files efficiently
	# h	- Human readable numbers in output
	# n	- Dry run
	RSYNC_COMMAND='rsync --delete --delete-excluded --partial -a -S '

	# Add a summary if desired
	if [ $SUMMARY ]; then
		RSYNC_COMMAND+='-h --itemize-changes '

		# ...and progress if we're running interactively
		[ -t 1 ] && RSYNC_COMMAND+='--progress '
	fi

	# Add the ignore file, if it exists
	[ -f "${IGNORE_LIST}" ] && RSYNC_COMMAND+="--exclude-from=${IGNORE_LIST} "

	# Add exclusions for each pattern
	if [ -n "${EXCLUDE}" ]; then
		for PATTERN in "${EXCLUDE[@]}"; do
			RSYNC_COMMAND+="--exclude='${PATTERN}' "
		done
	fi

	# Get the last backup directory, if present
	local LAST_BACKUP="$( newest "${DEST_DIR}" )"
	[ -d "${LAST_BACKUP}" ] && RSYNC_COMMAND+=" --link-dest=${LAST_BACKUP}"

	# Make a new backup directory
	if ! mkdir -p "$THIS_BACKUP"; then
		debug "Invalid destination directory"
		return 100
	fi

	# Run the backups
	backup_directories

	if [ ! "$?" -eq 0 ]; then

	else
		debug "Skipping the deletion due to errors"
		return	20
	fi
}
