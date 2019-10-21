##
# Get a weather forecast for our local area
##

# Set up the request URL. See wttr.in/:help for more.
# Flags:
# 0 - Only current weather
# Q - Super quiet version, no weathe report or city/location name
REQUEST="wttr.in/${1-95360}?0Q"

curl -H "Accept-Language: ${LANG%_*}" --compressed "$REQUEST"
