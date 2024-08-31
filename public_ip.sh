#!/usr/bin/env bash

if ! which dig 2>&1 > /dev/null; then
	echo '"dig" command not found'
	exit 1
fi

if [ "$( basename "$0" )" == "public_ipv4" ]; then
	DIG_ARGS='-4'
else
	DIG_ARGS='-t AAAA'
fi

echo "$( dig +short $DIG_ARGS myip.opendns.com @resolver1.opendns.com )"

