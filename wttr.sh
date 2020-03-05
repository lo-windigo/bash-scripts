##
# Get a weather forecast for our local area
##

ZIP="${1:-95360}"

# Set up the request URL. See wttr.in/:help for more.
# Flags:
# Q - Super quiet version, no weathe report or city/location name

# Full forecast flag
# 0 - Only current weather
FORECAST=
if [ "$( basename "$0" )" != 'forecast' ]; then
	FORECAST='0'
fi

REQUEST="wttr.in/${ZIP}?${FORECAST}Q"

curl -H "Accept-Language: ${LANG%_*}" --compressed "$REQUEST"
