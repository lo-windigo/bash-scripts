# Send input directly to command
command < "${1:-/dev/stdin}"

# Through while..read loop
while read -r line
do
  echo "$line"
done < "${1:-/dev/stdin}"
