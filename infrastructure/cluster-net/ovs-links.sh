#!/bin/bash
#######
# This script must be run as root or with sudo!
#######

usage() {
    echo "----------------------------------------------"
    echo "* This script creates OVS bridges for network"
    echo "* It requires a role variable be passed to setup"
    echo "* everything properly. See example below"
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

count=1
# Run this for Master
for br in bgp na-svc la-svc eu-svc af-svc as-svc au-svc external
do
    ovs-vsctl add-br $br
    ifconfig $br up
    ovs-vsctl set int $br mtu_request=1450
    case "$role" in
        master )
            ovs-vsctl add-port $br vx01-${br} -- set interface vx01-${br} type=vxlan options:remote_ip=10.10.2.11 options:key=111${count} options:dst_port=8765
            ovs-vsctl add-port $br vx02-${br} -- set interface vx02-${br} type=vxlan options:remote_ip=10.10.2.12 options:key=222${count} options:dst_port=8764
            ;;
        worker01 )
            ovs-vsctl add-port $br vx-${br} -- set interface vx-${br} type=vxlan options:remote_ip=10.10.2.10 options:key=111${count} options:dst_port=8765
            ;;
        worker02 )
            ovs-vsctl add-port $br vx-${br} -- set interface vx-${br} type=vxlan options:remote_ip=10.10.2.10 options:key=222${count} options:dst_port=8764
            ;;
    esac
    let count=$count+1
done
