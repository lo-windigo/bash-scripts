#!/usr/bin/env bash

##
## Sleepy VLC Player
##
##	Launch a "sleepy" instance of VLC that will shut itself down after a normal
##	movie-length of time (3 hours).
##

vlc -f $1 &

VLC_PID=$!

sleep 3h
kill $VLC_PID
