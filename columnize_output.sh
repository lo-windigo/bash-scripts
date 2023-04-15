#!/usr/bin/env bash
pr -5 -l1 -w$( tput cols ) "${1:-/dev/sdtin}"
