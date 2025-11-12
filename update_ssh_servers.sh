#!/usr/bin/env bash

# Save the new authorized hosts file
SSH_KEY_DIR="$( realpath ~/ssh_keys )"
SSH_HOSTS="$SSH_KEY_DIR/.ssh_servers"
AUTHORIZED_KEYS="$( realpath ~/.ssh/authorized_keys )"


# Set up SSH agent if needed
if [ -z "$SSH_AGENT_PID" ]; then
	echo "Missing a SSH agent"
	exit 1
fi


# Make sure temp file is writeable
if [ ! -w "$AUTHORIZED_KEYS" ]; then
	echo "Cannot write to the authorized keys file"
	exit 1
fi

# Make sure to copy the original file as a backup
AUTHORIZED_KEYS_CP_CMD="cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.old"
eval "$AUTHORIZED_KEYS_CP_CMD"

# Create the new authorized keys file
cat "$SSH_KEY_DIR/"* > "$AUTHORIZED_KEYS"

while read -u 7 HOST_TO_UPDATE; do

	echo "Updating authorized_keys for $HOST_TO_UPDATE"

	echo -n " - Backing up previous authorized_keys file: "
	if ssh $HOST_TO_UPDATE "$AUTHORIZED_KEYS_CP_CMD" > /dev/null; then
		echo "Successful"
	else
		echo "Failed"
	fi

	echo -n " - Copying new file to host"
	if scp "$AUTHORIZED_KEYS" "${HOST_TO_UPDATE}:.ssh/" > /dev/null; then
		echo "Successful"
	else
		echo "Failed"
	fi

	echo
done 7< "$SSH_HOSTS"

