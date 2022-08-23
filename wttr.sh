##
# Get a weather forecast for our local area
##

ZIP="${1:-93955}"

# Set up the request URL. See wttr.in/:help for more.
# Flags:
# Q - Super quiet version, no weathe report or city/location name

# Full forecast flag
# 0 - Only current weather
FORECAST='2'
if [ "$( basename "$0" )" != 'forecast' ]; then
	FORECAST='0'
fi

REQUEST="wttr.in/${ZIP}?${FORECAST}"

curl -H "Accept-Language: ${LANG%_*}" --compressed "$REQUEST"
