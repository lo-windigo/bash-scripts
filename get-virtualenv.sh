#!/usr/bin/env bash

##
## Find your parent virtualenv directory from ANYWHERE!
##
function get_virtualenv_dir {

	local TEST_DIR=

	# If no directory was sent in, this is the first time we've been called, and we
	# need to start at the current directory
	if [ -z "$1" ]; then
		if [ ! -z "$DEBUG" ]; then
			echo "Using current directory as the test directory" >&2
		fi
		TEST_DIR="$( pwd )"

	# If the specified argument is NOT a directory... BAIL OUT
	elif [ ! -d "$1" ]; then
		if [ ! -z "$DEBUG" ]; then
			echo "Invalid directory: ${1}" >&2
		fi
		return 10

	# If we're at the root, it's the end of the road... BAIL OUT
	elif [ "$1" = "/" ]; then
		if [ ! -z "$DEBUG" ]; then
			echo "Reached the root; no virtualenv found." >&2
		fi
		return 20

	# Use the directory sent in. We're pretty sure its legit
	else
		if [ ! -z "$DEBUG" ]; then
			echo "Using argument '${1}' as the test directory" >&2
		fi
		TEST_DIR="$1"
	fi


	# Check to see if there's an activate script available nearby
	if [ -d "${TEST_DIR}/bin" ] && [ -f "${TEST_DIR}/bin/activate" ]; then

		# This is a virtual environment! Send this directory to stdout
		echo "$TEST_DIR" 
		return 0

	# Start again, in the parent directory
	else
		if [ ! -z "$DEBUG" ]; then
			echo "Recursively calling: $( dirname ${TEST_DIR} )" >&2
		fi

		get_virtualenv_dir "$( dirname ${TEST_DIR} )"
	fi
}

# Call the function to get things kicked off
get_virtualenv_dir

