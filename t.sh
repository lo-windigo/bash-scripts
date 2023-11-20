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

if [ "$#" -eq 0 ]; then
	todo.sh $TODO_ARGS ls	
elif [ "$1" == "ls" ]; then
	todo.sh $TODO_ARGS $@	
else
	todo.sh $TODO_ARGS $@	
	todo.sh $TODO_ARGS ls	
fi

