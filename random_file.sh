#!/usr/bin/env bash

CURDIR="$( dirname "$( realpath "$0" )" )"

if [ ! -z "$1" ]; then
	DIR="'$1'"
fi

eval $CURDIR/random_file_listing.sh $DIR | head -n 1 
	
