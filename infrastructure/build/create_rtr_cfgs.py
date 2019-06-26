#!/usr/bin/python3
"""
Python script designed to generage frr router configurations for the Range network environment. In order for this script to
work properly, you need to write/modify the router_links.csv and default_environment.csv files.

TODO: Work on the custom_svc.csv integration so users can modify a simple csv file and get their services added to the network.
"""

import csv
import ipaddress
import os
from shutil import copyfile

bgp_reader = csv.reader(open('bgp_links.csv'))

bgp_links = {}

# Read in bgp_links.csv file and create dictionary keyed to the local router ASN for network configuration
# Then, for each ASN, map the service IPs for its associated service bridge interface into the svc_ips key
# in the dictionary. I realize this one-liner is not the most readable, and probably violates all kinds of
# "Pythonese", but it's the easiest way I could think of to make this work. I am open to suggestions if you
# think there is an easier way to do this! Please contribute, comment, or otherwise help out!
for row in bgp_reader:
    services_reader = csv.reader(open('default_environment.csv'))
    if row[0] != 'k8s_pod_name':
        bgp_links[row[2]] = {'k8s_pod_name':row[0],
                            'ovs_bridge_name':row[1],
                            'local_asn_network':row[3],
                            'remote_asns':str(row[4]).split(','), 
                            'external_net':row[6],
                            'svc_ips':[str(ipaddress.ip_network(svc[2] + "/24",strict=False)[1]) for svc in services_reader if svc[3] == row[5]]}

rtr_name = ''
local_net = ''
cfg_root = os.environ['CONFIG_HOME'] + "/network"

# Generate interface configration and write it to rtr-name/zebra.conf
for asn in bgp_links:
    rtr_name = bgp_links[asn]['k8s_pod_name']
    local_net = bgp_links[asn]['local_asn_network']
    cfg_path = cfg_root + rtr_name

    # Create config directory if it doesn't already exist
    if not os.path.exists(cfg_path):
        os.mkdir(cfg_path)

    # Create config files
    bgpd = open(cfg_path + '/bgpd.conf', 'w+')
    zebra = open(cfg_path + '/zebra.conf', 'w+')

    # Interface count for beginning interfaces in config files
    int_count = 1
    bgpd.write("!\nhostname " + bgp_links[asn]['k8s_pod_name'] + "\n!\n" + "router bgp " + asn + "\n")
    zebra.write("!\nhostname " + rtr_name + "\n!\n!\n!\ninterface net" + str(int_count) + "\n")
    zebra.write("  ip address " + str(ipaddress.ip_network(local_net)[1]) + '/' + local_net.split('/')[1] + "\n!\n")

    # Iterate count for interface names starting in the loop
    int_count += 1
    for remote_asn in bgp_links[asn]['remote_asns']:
        remote_network = bgp_links[remote_asn]['local_asn_network']

        # Write remote AS associations
        bgpd.write("neighbor " + str(ipaddress.ip_network(remote_network)[2]) + " remote-as " + remote_asn + "\n")

        # Write remote asn config data
        if bgp_links[asn]['remote_asns'].index(remote_asn) != 0:
            zebra.write("interface net" + str(int_count) + "\n")
            zebra.write("  ip address " + str(ipaddress.ip_network(remote_network)[2]) + '/' + remote_network.split('/')[1] + "\n")
            zebra.write("!\n")
            int_count += 1

    zebra.write("!\n")
    zebra.write("interface net" + str(int_count) + "\n")
    bgpd.write("!\n!\n address-family ipv4 unicast\n")
 
    for svc_ip in bgp_links[asn]['svc_ips']:
        # Write BGP network advertisement addresses
        bgpd.write("  network " + str(ipaddress.ip_network(svc_ip + "/24",strict=False)) + "\n")

        # Write service networks
        zebra.write("  ip address " + str(ipaddress.ip_network(svc_ip + "/24",strict=False)[1]) + "/24\n")

    int_count += 1
    ext_net = bgp_links[asn]['external_net']
    zebra.write("!\n")
    zebra.write("interface net"  + str(int_count) + "\n")
    zebra.write("  ip address " + str(ipaddress.ip_network(ext_net,strict=False)[1]) + "/" + ext_net.split('/')[1] + "\n")

    bgpd.write("  network " + ext_net + "\n")
    bgpd.write("!\n!\nline vty\n!\n")

    zebra.write("!\n")
    zebra.close()
    bgpd.close()
    copyfile("build/routers/daemons", cfg_path + "daemons")
