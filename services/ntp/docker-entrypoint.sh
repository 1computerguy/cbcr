#!/bin/sh

#!/bin/sh
set -e

usage () {
    echo " -s  specify ntp server sources e.g. '-s time.apple.com time.google.com'";
    echo " --  to send arguments to chronyd e.g. '-- --help'";
    exit 0;
}

numServers=0
setServers() {
    sed -i '/server .*/d' /etc/chrony.conf

    echo >> /etc/chrony.conf
    echo "# NTP Servers" >> /etc/chrony.conf

    old_IFS=$IFS
    IFS=' '
    for server in "$@"
    do
        numServers=$((numServers+1))
        if [ "$server" = '--' ]; then
            break
        fi
        echo "server $server iburst" >> /etc/chrony.conf
    done
    IFS=$old_IFS
}

while getopts "h?s" opt; do
    case "$opt" in
        h|\?) usage;;
        s) shift; setServers "$@";;
        * ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
    esac
done

shift "$numServers"

# Remove leftover pid file from previous runs
if [ -f /var/run/chrony/chronyd.pid ]; then
    rm -f /var/run/chrony/chronyd.pid
fi

if [ $# -eq 0 ]; then
# https://chrony.tuxfamily.org/doc/3.3/chronyd.html
# -d = Don't detach from terminal and log to stdout/stderr
# -F = Enable system call filter (seccomp)
#      in level 1 the process is killed when a forbidden system call is made,
#      in level -1 the SIGSYS signal is thrown instead and
#      in level 0 the filter is disabled (default 0).
# -s = Set the system clock from the computer’s real-time clock (RTC)
#      or to the last modification time of the file specified by
#      the driftfile directiv
    exec /usr/local/sbin/chronyd -d -F 1 -s
fi

ip addr add $IP_ADDR/$LEN dev net1
ip link set mtu 1450 dev net1
ip r d default
ip r a default via $GATEWAY

[ "$1" = '--' ] && shift
exec /usr/local/sbin/chronyd "$@"
