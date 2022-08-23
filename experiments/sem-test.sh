#!/usr/bin/env bash

# Let's test semaphores!

for X in {1..5}; do
	echo "Starting long running process ${X}"
	sleep 5
	echo "Long running process ${X} completed."
	sem -u -j 150% --id=gm "echo ' - Starting processing on result of ${X}'; sleep 5; echo ' - Processing ${X} completed.'"
	echo "Registered semaphore for processing ${X}"
done

sem --wait --id=gm
