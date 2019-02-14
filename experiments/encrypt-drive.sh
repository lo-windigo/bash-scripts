cryptsetup --verbose -c twofish-xts-plain64 -h whirlpool --key-size 512 \
	luksFormat /dev/sdX
