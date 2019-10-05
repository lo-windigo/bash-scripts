#!/usr/bin/env bash
#
# Synchronize the podcasts on my
# Samsung phone
#
#######################################


# Configurations
DEBUG="YES"
PHONE_DIR="${HOME}/phone-tmp"
#PHONE_PODCAST_DIR="${PHONE_DIR}/Podcasts"
PHONE_PODCAST_DIR="${PHONE_DIR}"
SOURCE_DIR="/data/podcasts/sync"
SOURCE_SYNC_FILE="${SOURCE_DIR}/.device_sync"
C_NEW="$( tput setaf 2 )"
C_MISSING="$( tput setaf 1 )"
C_RST="$( tput sgr0 )"


# Make sure we clean up our mounts on exit
function clean_up_mounts {
	fusermount -uz "$PHONE_DIR"
	rmdir "$PHONE_DIR"
}

trap clean_up_mounts EXIT

# Keep track of the longest filename discovered
LONGEST_FILE=0
function update_longest_file {
	[ "${#1}" -gt "$LONGEST_FILE" ] && LONGEST_FILE=${#1}
}

# Mount the MTP device in a temporary directory
mkdir -p "$PHONE_DIR"
if ! sshfs -o idmap=user phone: "$PHONE_DIR"; then
	echo "SSH command failed; please check the connection to the phone."
	exit 10
fi

# Check to make sure that the phone was mounted properly
if [ -z "ls -A ${PHONE_DIR}" ] || [ ! -d "$PHONE_PODCAST_DIR" ]; then
	rmdir "$PHONE_DIR"
	echo "Could not mount the phone; make sure the FTP server is active."
	exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
	echo "Source podcast directory does not seem to be present"
	exit 2
fi


# Start "missing files" arrays
declare -a MISSING_FROM_PHONE MISSING_FROM_SOURCE NEW_IN_SOURCE

# If the "last synchronized" file exists, utilize it to delete old episodes
if [ -e "$SOURCE_SYNC_FILE" ]; then
	
	# For each file present before last sync, check to see if it was deleted on
	# the device - and then delete it from the source as well
	while read EPISODE_FULL; do
		EPISODE="$( basename $EPISODE_FULL )"
		if [ ! -e "${PHONE_PODCAST_DIR}/$EPISODE" ]; then
			MISSING_FROM_PHONE+=( "$EPISODE" )
			update_longest_file "$EPISODE"
		fi
	done < <( find "${SOURCE_DIR}/"* ! -cnewer "$SOURCE_SYNC_FILE" \
		! -name "$( basename $SOURCE_SYNC_FILE )" )

	# Check to see if there are episodes on the device that aren't present
	# in the sync dir, and delete those too (since we're not using rsync)
	while read EPISODE_FULL; do
		EPISODE="$( basename $EPISODE_FULL )"
		if [ ! -e "${SOURCE_DIR}/${EPISODE}" ]; then
			MISSING_FROM_SOURCE+=( "$EPISODE" )
			update_longest_file "$EPISODE"
		fi
	done < <( find "${PHONE_PODCAST_DIR}/"* ! -name "$( basename $SOURCE_SYNC_FILE )" )
	
else
	[ -n "$DEBUG" ] && echo "No previous sync file; assuming we're starting from scratch"
	touch --date="1999-12-31 23:59:59" "$SOURCE_SYNC_FILE"
fi

# Check for new podcasts
while read EPISODE_FULL; do
	EPISODE="$( basename $EPISODE_FULL )"
	NEW_IN_SOURCE+=( "$EPISODE" )
	update_longest_file "$EPISODE"
done < <( find "$SOURCE_DIR/"* -cnewer "$SOURCE_SYNC_FILE" ! -name "$( basename $SOURCE_SYNC_FILE )" )

# Print out an informational screen, and prompt the user for what to do
echo "The following files have been removed from one location or another, and"
echo "will be deleted:"
echo "----------------------------------------------------------------------"
echo "Missing from phone: ${C_MISSING}${MISSING_FROM_PHONE[@]}${C_RST}"
echo "Missing from sync: ${C_MISSING}${MISSING_FROM_SOURCE[@]}${C_RST}"
echo
echo "The following new episodes will be copied to the device:"
echo "----------------------------------------------------------------------"
echo "${C_NEW}${NEW_IN_SOURCE[@]}${C_RST}"
echo
echo -n "Type 'y' to proceed with operations: "
read CONFIRMATION
echo
echo

if [ "$CONFIRMATION" == "y" ]; then

	# Remove old episodes from the phone
	for EPISODE in "${MISSING_FROM_PHONE[@]}"; do
		EPISODE_FULL="${SOURCE_DIR}/${EPISODE}"
		[ -n "$DEBUG" ] && echo "${C_MISSING} - ${EPISODE_FULL}${C_RST}"
		rm "$EPISODE_FULL"
	done

	# Remove old episodes from the sync directory
	for EPISODE in "${MISSING_FROM_SOURCE[@]}"; do
		EPISODE_FULL="${PHONE_PODCAST_DIR}/$EPISODE" 
		[ -n "$DEBUG" ] && echo "${C_MISSING} - ${EPISODE_FULL}${C_RST}"
		rm "$EPISODE_FULL"
	done

	# Copy the new episodes
	for EPISODE in "${NEW_IN_SOURCE[@]}"; do
		EPISODE_FULL="${SOURCE_DIR}/${EPISODE}"
		[ -n "$DEBUG" ] && echo "${C_NEW} + ${EPISODE_FULL}${C_RST}"
		#cp -n "$EPISODE_FULL" "${PHONE_PODCAST_DIR}/"
		scp "$EPISODE_FULL" phone:
	done

	# Update the sync'd file, unmount the phone, and delete the temp directory
	[ -n "$DEBUG" ] && echo "Updating sync file, unmounting & removing temp directory"
	touch "$SOURCE_SYNC_FILE"
else
	echo "Well then, nothing to do here."
fi

