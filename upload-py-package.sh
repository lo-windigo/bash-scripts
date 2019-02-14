#!/usr/bin/env bash

# Make sure we are within the virtualenv
VENV="$( get-virtualenv )"

if [ -z "$VENV" ]; then
	echo "We are not currently in a virtualenv. Exiting." >&2
	exit 10
fi

. "${VENV}/bin/activate"

twine upload --repository-url https://test.pypi.org/legacy/ dist/*
