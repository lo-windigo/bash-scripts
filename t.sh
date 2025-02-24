#!/usr/bin/env bash

##
## TODO.txt command wrapper
##

if ! which todo.sh > /dev/null; then
	echo '"todo.sh" not found'
	exit 1
fi

if [ -t 1 ]; then
	TODO_COLOR_FLAG=c
else
	TODO_COLOR_FLAG=p
fi

TODO_ARGS=" -${TODO_COLOR_FLAG}tN"

# If we have arguments, we should probably run them
if [ "$#" -ne 0 ]; then
	todo.sh $TODO_ARGS $@	
fi

# If we haven't been called with a list-y command, we should list todo items
if [ "$1" != "ls" ] && [ "${1:0:4}" != 'list' ]; then
	todo.sh $TODO_ARGS ls	
fi

