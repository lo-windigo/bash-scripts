#!/usr/bin/env bash

for IMAGE in $@; do

	/usr/bin/gm mogrify -auto-orient -resize 1200x1200 -strip "$IMAGE"

done
