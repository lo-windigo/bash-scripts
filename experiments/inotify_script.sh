inotifywait -m -e create -e moved_to --format "%f" $TARGET \
	| while read FILENAME
		do
				echo Detected $FILENAME, moving and zipping
				mv "$TARGET/$FILENAME" "$PROCESSED/$FILENAME"
				gzip "$PROCESSED/$FILENAME"
		done
