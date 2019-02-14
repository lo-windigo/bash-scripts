#!/usr/bin/env bash

# Make sure we are within the virtualenv
VENV="$( get-virtualenv )"

if [ -z "$VENV" ]; then
	echo "We are not currently in a virtualenv. Exiting." >&2
	exit 10
fi

. "${VENV}/bin/activate"

TEST_FILES=( setup.py dist )

for F in "${TEST_FILES[@]}"; do
	if [ ! -e "$F" ]; then
		echo "Cannot find ${F}; exiting." >&2
		exit 20
	fi
done

# Clean out the dist folder first
rm dist/*

# Build the package
python setup.py sdist bdist_wheel
