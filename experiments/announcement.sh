#!/usr/bin/env bash

RECIPIENTS=( \
	"test@example.com" \
)


for SEND_TO in ${RECIPIENTS[@]}; do

	mail -s "Test message" \
		 -a 'From:test@example.net' \
		 $SEND_TO <<MESSAGE
Body of the email
MESSAGE

	# wait a while, to prevent being seen as a spammer
	sleep 10s
done
