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

echo "Local system:"
echo " - Backing up local authorized_keys file"
eval "$AUTHORIZED_KEYS_CP_CMD"

echo " - Create the new authorized keys file"
cat "$SSH_KEY_DIR/"* > "$AUTHORIZED_KEYS"

echo 

while read -u 7 HOST_TO_UPDATE; do

	echo "Remote $HOST_TO_UPDATE:"

	echo -n " - Backing up previous authorized_keys file: "
	if ssh $HOST_TO_UPDATE "$AUTHORIZED_KEYS_CP_CMD" 2>/dev/null; then
		echo "Successful"
	else
		echo "Failed"
	fi

	echo -n " - Copying new file to host: "
	if scp -q "$AUTHORIZED_KEYS" "${HOST_TO_UPDATE}:.ssh/" 2>/dev/null; then
		echo "Successful"
	else
		echo "Failed"
	fi

	echo
done 7< "$SSH_HOSTS"

echo "Updates complete"

