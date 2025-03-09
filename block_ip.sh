#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "Missing argument."
	echo
	echo "  Usage: $0 ip-address"

	exit
fi

sudo /sbin/route add -host "$1" reject
