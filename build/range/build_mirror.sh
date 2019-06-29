#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Add a mirror to OVS bridge"
    echo "NOTE: a tap interface is added first, then that tap is configured as"
    echo "the mirror interface below. It is then used for network monitoring"
    echo "using the Bro IDS"
    echo "Usage: $0 <bridge> <output port>"
    echo "Example: $0 bgp bro0"
    exit 1
fi

BR=$1
OUTPUT_PORT=$2

sudo ip tuntap add mode tap $OUTPUT_PORT

sudo ip link set up dev $OUTPUT_PORT

ovs-vsctl add-port $BR $OUTPUT_PORT \
  -- --id=@m create mirror name=m0 \
  -- add bridge $BR mirrors @m \
  -- --id=@port get port $OUTPUT_PORT \
  -- set mirror m0 output-port=@port