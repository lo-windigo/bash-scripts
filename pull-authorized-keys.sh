#!/usr/bin/env bash

DEBUG=1
TMP_AUTH_KEYS="${TMP:-/tmp}/authorized_keys.tmp"
DEST_AUTH_KEYS="${HOME:-.}/.ssh/authorized_keys"

ssh windigo@tty.sdf.org '$HOME/bin/public_keys' > "$TMP_AUTH_KEYS"

if [ -s $TMP_AUTH_KEYS ]; then
	mv "$DEST_AUTH_KEYS" "${DEST_AUTH_KEYS}.old"
	mv "$TMP_AUTH_KEYS" "$DEST_AUTH_KEYS"

	[ $DEBUG ] && echo 'Authorized keys file updated successfully'
elif [ $DEBUG ]; then
	echo 'Failed to update authorized keys; bad data from remote'
fi
