#!/usr/bin/env bash

##
## TODO.txt command wrapper
##

if [ -t 1 ]; then
	TODO_COLOR_FLAG=c
else
	TODO_COLOR_FLAG=p
fi

TODO_ARGS=" -${TODO_COLOR_FLAG}tNd ${HOME}/.config/todo.sh/todo.cfg"

cd $HOME/opt/todo.txt-cli

if [ "$#" -eq 0 ]; then
	./todo.sh $TODO_ARGS ls	
else
	./todo.sh $TODO_ARGS $@	
fi

