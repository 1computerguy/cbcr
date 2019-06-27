#!/bin/sh

ip addr add $IP_ADDR/$LEN dev net1
ip link set mtu 1450 dev net1
ip r d default
ip r a default via $GATEWAY

/run.sh -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R -P $PUBLICHOST