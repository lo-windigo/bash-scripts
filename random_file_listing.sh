#!/usr/bin/env bash

if [ -z "$1" ]; then
	RANDOM_ROOT='./'
else
	RANDOM_ROOT="$1"
fi

RANDOM_ROOT_REAL="$( realpath "$RANDOM_ROOT" )"

if [ ! -d "$RANDOM_ROOT_REAL" ]; then
	echo "Path specified is not a directory: $1"
	exit 9
fi

# Return a single random file
find "$RANDOM_ROOT_REAL" -type f | sort -R
	
