#!/usr/bin/python3

import csv
import datetime
import os
import glob
import sys
from shutil import copyfile, copytree

def forward_dns(domain, dict_list, auth_named, timestamp):
    # Generate DNS file

    # Header
    dns = """$TTL  86400
@       IN      SOA     ns1.{arg1}. dns-admin.{arg1}. (
                        {arg2}         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
""".format(arg1=domain, arg2=timestamp)

    # Begin generation of Bind9 db file content
    for vals in dict_list:
        # If the full domain name is the same as the base domain name then we just
        # need to generate a standard A record.
        if vals["full_domain_name"] == domain:
            dns += "{arg1}.      IN      A       {arg2}\n".format(arg1=domain, arg2=vals["ip_address"])

        # If service type is not web server, just add A record. This is used for ftp, smtp, and other
        # services that don't use the www CNAME entry.
        elif vals["svc_type"] != "web":
            dns += "{arg1}.      IN      A       {arg2}\n".format(arg1=vals["full_domain_name"], arg2=vals["ip_address"])

        # For all other entries, add A records for the full domain as well base domain. Since this is a
        # relatively simple network, both of these are the same.
        else:
            dns += "{arg1}.      IN      A       {arg2}\n".format(arg1=vals["full_domain_name"], arg2=vals["ip_address"])
            dns += "{arg1}.      IN      A       {arg2}\n".format(arg1=domain, arg2=vals["ip_address"])

        # If the service is a web server, add the "www" CNAME entry to redirect to the
        # full domain name. Makes both www.google.com and google.com valid DNS entries
        # NO, this is not automatic...
        if vals["svc_type"] == "web":
            dns += "www.{arg1}.     IN      CNAME       {arg2}.\n".format(arg1=domain, arg2=domain)

    # Add MX records
    for vals3 in dict_list:
        if vals3["svc_type"] == "smtp":
            dns += "{arg1}.      IN      MX      10  {arg2}.\n".format(arg1=domain, arg2=vals3["full_domain_name"])

    # Add nameservers
    for server in auth_named:
        dns += "{arg1}.     IN    NS    {arg2}.\n".format(arg1=domain, arg2=server)

    return dns


def reverse_dns(dns_ips, auth_named, timestamp):
    # Generate output content for reverse dns records. Used formatted strings to
    # create the output. This is written to a series of files in the ./reverse
    # folder. These files are then added to the named.conf file in the bind9 root
    # directory.
    #
    # Generate DNS file header
    dns = """$TTL  86400
@       IN      SOA         ns1.{arg1}. dns-admin.{arg1}. (
                            {arg2}         ; Serial
                            604800         ; Refresh
                            86400         ; Retry
                            2419200         ; Expire
                            604800 )       ; Negative Cache TTL
""".format(arg1=domain, arg2=timestamp)

    # Add reverse pointer records
    for vals in entries:
        dns += "{arg1}.      IN      PTR       {arg2}\n".format(arg1=vals["reverse_address"], arg2=vals["full_domain_name"])

    # Add nameservers
    for ns in auth_named:
        dns += "                 IN      NS      {arg1}\n".format(arg1=ns)

    return dns


def named_dns(dns_files_dir):
    named = """// BIND Configuration
include "/etc/bind/rndc.key";
controls {
    inet 127.0.0.1 port 953 allow { 127.0.0.1; };
};
logging {
    category default { null; };
};
zone "." {
    type hint;
    file "/etc/bind/db.root";
};
zone "localhost" {
    type master;
    file "/etc/bind/db.local";
    allow-update { none; };
};
zone "0.0.127.in-addr.arpa" {
    type master;
    file "/etc/bind/db.127";
    allow-update { none; };
};
zone "255.in-addr.arpa" {
    type master;
    file "/etc/bind/db.255";
    allow-update { none; };
};
zone "0.in-addr.arpa" {
    type master;
    file "/etc/bind/db.0";
    allow-update { none; };
};
options {
    directory "/etc/bind";
    dump-file "/etc/bind/data/cache_dump.db";
    statistics-file "/etc/bind/data/named_stats.txt";
    recursion no;
    allow-recursion { none; };
    allow-query { any; };
    allow-query-cache { any; };
    listen-on-v6 { none; };
    listen-on { any; };
};
"""
    # Generate named.conf output for forward-lookup zones
    named_files = dns_files_dir + "/db.*"
    for filename in glob.glob(named_files):
        forward_file = os.path.basename(filename)
        forward_domain = '.'.join(forward_file.split('.')[1:])
        named += """zone "{domain_name}" {{
    type master;
    file "/etc/bind/{domain_file}";
    allow-update {{ none; }};
}};
""".format(domain_name=forward_domain, domain_file=forward_file)

    # Generate named.conf output for reverse-lookup zones
    reverse_files = dns_files_dir + "/reverse-zones/db.*"
    for filename in glob.glob(reverse_files):
        reverse_file = os.path.basename(filename)
        reverse_domain = '.'.join(reverse_file.split('.')[1:])
        named += """zone "{zone_number}.in-addr.arpa" {{
    type master;
    file "/etc/bind/reverse_zones/{domain_file}";
}};
""".format(zone_number=reverse_domain, domain_file=reverse_file)

    return named



# Grab save directory from command line
build_file = sys.argv[1]

if not sys.argv[2]:
    write_directory = os.environ["CONFIG_HOME"] + "/dns"
else:
    write_directory = sys.argv[2]

reverse_directory = write_directory + "/reverse-zones"
dns_build_dir = os.environ["REPO_HOME"] + "/range_svcs/services/dns"

# Make required directories for DNS servers if they don't already exist
if not os.path.exists(write_directory):
    os.makedirs(write_directory)

if not os.path.exists(reverse_directory):
    os.makedirs(reverse_directory)

# import range_services.csv file - maybe accept this as an argument - consider...
services_reader = csv.reader(open(build_file))

# Generate timestamp for DNS serial - useful if changes are made so Bind will
# automatically update - so long as the serial is updated
time = '{0:%Y%m%d%H}'.format(datetime.datetime.now())
    
forward_svcs = {}
reverse_ips = {}
nameservers = []

# Iterate over the imported csv file and get the necessary data
#    - Needed for dns from the range_services.csv file:
#       - full domain name
#       - base domain name (this will be the Bind db file created)
#       - IP address
#       - Service type - to know what type of records to generate
#       - Sub service type - necessary for some MX record and other processing
#
#   - Add something for the "flat" DNS configuration that selects the root
#       servers in lieu of the tiered DNS and the auth servers
#       May have to rewrite portions to change nameserver addresses...
for row in services_reader:
    if row[0] != 'svc_category':
        if row[6] != '':
            if row[6] in forward_svcs:
                forward_svcs[row[6]].append({'full_domain_name':row[1],
                                    'ip_address':row[2],
                                    'svc_type':row[4],
                                    'svc_sub_type':row[5]})
            else:
                forward_svcs[row[6]] = [{'full_domain_name':row[1],
                                'ip_address':row[2],
                                'svc_type':row[4],
                                'svc_sub_type':row[5]}]

            # Create dictionary of dictionaries keyed on the last octet of the IP
            # The last-octet will be used to create the necessary Bind9 reverse
            # lookup files.
            last_octet = row[2].split('.')[3]
            first_three = '.'.join((row[2].split('.')[:3][::-1]))
            if last_octet in reverse_ips:
                reverse_ips[last_octet].append({'full_domain_name':row[1],
                                    'reverse_address':first_three})
            else:
                reverse_ips[last_octet] = [{'full_domain_name':row[1],
                                'reverse_address':first_three}]

        # Generate list of authoritative nameservers
        if row[5] == 'authoritative':
            nameservers.append(row[1])

# write forward zone db files
for domain, dict_list in forward_svcs.items():
    forward_file = write_directory + "/db." + domain
    with open(forward_file, 'w') as forward_write:
        forward_write.write(forward_dns(domain, dict_list, nameservers, time))

# write reverse-zone db files
for domain, entries in reverse_ips.items():
    reverse_file = reverse_directory + "/db." + domain
    with open(reverse_file, 'w') as reverse_write:
        reverse_write.write(reverse_dns(reverse_ips, nameservers, time))

named_file = write_directory + "/named.conf"
# Write named.conf to file
with open(named_file, 'w') as named_write:
    named_write.write(named_dns(write_directory))

for full_filename in glob.glob(dns_build_dir + "/auth/*"):
    filename = os.path.basename(full_filename)
    copyfile(full_filename, write_directory + "/auth/" + filename)

copytree(dns_build_dir + "/recursive", write_directory)
copytree(dns_build_dir + "/root", write_directory)