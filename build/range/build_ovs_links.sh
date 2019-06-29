#!/bin/bash
#######
# This script must be run as root or with sudo!
#######

role=""

usage() {
    echo "---------------------------------------------------------"
    echo "* This script creates OVS bridges for network"
    echo "* It requires a role variable be passed to setup"
    echo "* everything properly. See example below"
    echo "*"
    echo "* $0 -r <role> -l br1 br2 br3 brN"
    echo "*"
    echo "* Acceptable roles: master, worker01, worker02"
    echo ""
    echo " NOTE: if role is left blank, system hostname"
    echo "  will be used. If hostname does not match the"
    echo "  above roles, the script will exit and do nothing"
    echo "----------------------------------------------------------"
    exit 0
}

create_bridges() {
    #bridges = (bgp rtr1-svc rtr2-svc rtr3-svc rtr4-svc rtr5-svc rtr6-svc external)
    br="$1"
    count="$2"
    role="$3"

    ovs-vsctl add-br $br
    ifconfig $br up
    ovs-vsctl set int $br mtu_request=1450
    case "$role" in
        master )
            ovs-vsctl add-port $br vx01-${br} -- set interface vx01-${br} type=vxlan options:remote_ip=10.10.2.11 options:key=111${count} options:dst_port=4789
            ovs-vsctl add-port $br vx02-${br} -- set interface vx02-${br} type=vxlan options:remote_ip=10.10.2.12 options:key=222${count} options:dst_port=4789
            ;;
        worker01 )
            ovs-vsctl add-port $br vx-${br} -- set interface vx-${br} type=vxlan options:remote_ip=10.10.2.10 options:key=111${count} options:dst_port=4789
            ;;
        worker02 )
            ovs-vsctl add-port $br vx-${br} -- set interface vx-${br} type=vxlan options:remote_ip=10.10.2.10 options:key=222${count} options:dst_port=4789
            ;;
    esac
}

if [ $# -gt 0 ]
then
    while [ "$1" != "" ]
    do
        case "$1" in
            -r | --role )
                shift
                role="$1"
                shift
                ;;
            -l | --list )
                shift
                count=1
                if [ "$role" == "" ]
                then
                    role=`cat /etc/hostname`
                fi
                while [ "$1" != "" ]
                do
                    create_bridges "$1" "$count" "$role"
                    shift
                    let count+=1
                done
                ;;
            -h | --help )
                usage
                ;;
        esac
    done
else
    usage
fi


