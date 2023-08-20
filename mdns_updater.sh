#!/usr/bin/env bash

if ! which dig 2> /dev/null; then
	echo '"dig" package required'
	exit 1
fi

function mdns_ip {
	dig @8.8.8.8 windigo.mdns.org +short 
}

WAN_IPV4=$( dig @resolver4.opendns.com myip.opendns.com +short )
#WAN_IPV6=$( dig @ns1.google.com TXT o-o.myaddr.l.google.com +short -6 )
MDNS_IP=$( mdns_ip ) 

if [ "$WAN_IPV4" != "$MDNS_IPV4" ]; then
	ssh sdf "mdns $WAN_IPV4"
fi
