#!/usr/bin/env bash

# Start a tmux session if we're connected via SSH
# via http://hacker-vaillant-rien-d-impossible.com/public/linux/tmux
if which tmux &> /dev/null && [ "${TERM:0:6}" != "screen" ]; then

	TMUX_CMD='tmux -u -2'
	# Check for an existing tmux session, and attach if there. Otherwise start
	#    a new session.
	if tmux ls &> /dev/null; then
		exec $TMUX_CMD attach
	else
		# We're starting a new session; make sure we have a SSH agent
		cd $HOME/codesource/clp
		sed -i 's/256m/512m/' docker-compose.yaml
		exec $TMUX_CMD new-session \; send -t 0:0.0 'make run-apache-dev' C-m
	fi
fi
