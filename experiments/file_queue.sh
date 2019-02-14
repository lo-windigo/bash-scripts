#!/usr/bin/env bash

# Settings
QUEUE_FILE='queue.dat'


# Fill the queue from a file
function fill_queue {

	local OLD_IFS="$IFS"
	IFS=$'\n'

	# Use each queue file line as an array element
	QUEUE=( $( cat $QUEUE_FILE ) )
	
	IFS="$OLD_IFS"
}


# Remove a value from the top
function pop_queue {

	# Sanity check: Don't mess with an empty array
	if [ ${#QUEUE[@]} -eq 0 ]; then
		return
	fi

	# Return the first value, and remove it from the array
	echo 
	echo "Queue value: ${QUEUE[0]}"
	echo
	unset QUEUE[0]

	# Reindex the array
	QUEUE=( "${QUEUE[@]}" )
}


# Add a value to the top
function push_queue {
	local VALUE="$@"
	local OLD_IFS="$IFS"
	IFS=$'\n'
	local NEW_QUEUE=( "$VALUE" )
	NEW_QUEUE+=( ${QUEUE[@]} )
	QUEUE=( ${NEW_QUEUE[@]} )
	IFS="$OLD_IFS"
}


# Dump out whatever's in our queue
function print_queue {

	echo
	echo "Printing current queue:"
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

	for ITEM in "${QUEUE[@]}"; do
		echo $ITEM
	done

	echo
}


# Save the queue to file
function save_queue {

	# Clear out the queue file first
	echo > "$QUEUE_FILE"

	# Save the queue stuff back to file
	for ITEM in "${QUEUE[@]}"; do
		echo "$ITEM" >> "$QUEUE_FILE"
	done
}


# Handle program interactions
fill_queue

if [ "$#" -eq 0 ]; then
	print_queue
elif [ "$1" == "pop" ]; then
	pop_queue
	save_queue
elif [ "$1" == "push" ]; then
	push_queue "$2"
	save_queue
fi

