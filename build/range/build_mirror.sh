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

br=$1
output_port=$2

ovs-vsctl add-port $br output_port \
  -- set interface $br type=internal \
  -- --id=@p get port $output_port \
  -- --id=@m create mirror name=m0 \
  select-all=true output-port=@p \
  -- set bridge $br mirrors=@m

sudo ip link set up dev $output_port
