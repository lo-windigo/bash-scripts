#!/usr/bin/env bash

SEARCH_DIR="$1"

if [ -z "$SEARCH_DIR" ]; then
	SEARCH_DIR=$( pwd )
fi

RANDOM_DIR=$( find "$SEARCH_DIR"  -mindepth 1 -type d | sort -R | head -n 1 )

if [ -z "$RANDOM_DIR" ]; then
	echo $SEARCH_DIR
else
	echo "Recursing: $0 $RANDOM_DIR" >&2
	eval "$0 '$RANDOM_DIR'"
fi

