# Make sure nbd is loaded
sudo modprobe nbd

# Set up a local NBD bridge to the backup disk via SSH tunnel
nbdkit ssh host=jon_nas backups.disk

# Possible performance improvements
nbdkit -n -e jon_backups --exit-with-parent --threads 4 \
	ssh host=jon_nas backups.disk &

# Single-threaded option
nbdkit -n -e jon_backups --exit-with-parent \
	ssh host=jon_nas backups.disk &

# Mount the remote disk as a local NBD device
sudo nbd-client -name jon_backups localhost /dev/nbd0

# CRYPTSETUP AND BACKUPS GO HERE

# Disconnect the NBD device
sudo nbd-client -d /dev/ndb0
