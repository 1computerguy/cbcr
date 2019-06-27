#!/bin/bash
#######
# This script must be run as root or with sudo!
#######

usage() {
    echo "----------------------------------------------"
    echo "* This script creates OVS bridge mirror for Bro"
    echo "* IDS monitoring. It will monitor the bgp bridge"
    echo "* for each worker, and the external connection"
    echo "* bridge for the master."
    echo "*"
    echo "* $0 <role>"
    echo "*"
    echo "* Acceptable roles: master, worker01, worker02"
    echo ""
    echo " NOTE: if role is left blank, system hostname"
    echo "  will be used. If hostname does not match the"
    echo "  above roles, it will cause problems"
    echo "-----------------------------------------------"
    exit
}

if [ $# -gt 0 ]
then
    case "$1" in
        -h | --help )
            usage
            ;;
    esac
    role="$1"
else
    role=`cat /etc/hostname`
fi

case "$role" in:
    master )
        ovs-vsctl add-port external bro0 -- set interface bro0 type=internal -- --id=@p get port bro0 -- --id=@m create mirror name=m0 select-all=true output-port=@p -- set bridge external mirrors=@m
        ip link set bro0 up
        ;;
    worker01 | worker02 )
        ovs-vsctl add-port bgp bro0 -- set interface bro0 type=internal -- --id=@p get port bro0 -- --id=@m create mirror name=m0 select-all=true output-port=@p -- set bridge bgp mirrors=@m
        ip link set bro0 up
        ;;
esac

