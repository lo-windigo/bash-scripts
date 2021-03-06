#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "newest" 1>&2
	echo "Find the oldest dated subfolder inside a directory" 1>&2
	echo 1>&2
	echo "Usage: $( basename $0 ) /path/to/directory" 1>&2
	echo 1>&2

	exit 10
fi

if [ ! -d "$1" ]; then
	echo "Invalid directory specified" 1>&2

	exit 20
fi

DIRECTORY="$( dirname "$1" )/$( basename "$1" )"
find "$DIRECTORY" -maxdepth 1 -mindepth 1 -type d | sort | head -n 1 
