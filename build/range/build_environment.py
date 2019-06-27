#!/usr/bin/python

import geoip2.database
import dns.resolver
import argparse
import os
from ipaddress import IPv4Network
from ruamel.yaml import YAML
from ruamel.yaml.scalarstring import PreservedScalarString as pss

parser = argparse.ArgumentParser()
parser.add_argument('-d','--domian', help='This is the domain to look up.', required=True)
args = parser.parse_args()

maxmind_db = '/range/infrastructure/geoip/GeoLite2-City.mmdb'

# Example: domain_to_ip_and_location('google.com', maxmind_db)
def domain_to_ip_and_location(domain_name, location_db, fidelity="LOW"):
    """Function used to build service links for varying network fidelities"""
    reader = geoip2.database.Reader(location_db)

    site_ip = str([(rdata) for rdata in dns.resolver.query(domain_name, 'A')][0])

    # Used for network links/service locations
    continent = str(reader.city(site_ip).continent.name)

    # Used for higher fidelity network links (in the event that a more complex network is built) that requires more bridges
    country = str(reader.city(site_ip).country.name)

    # Write output to CSV

def build_dns():
    """Do dns building stuff"""

def build_routers():
    """Build frr router configs"""

def build_smtp():
    """Build smtp mail configs"""

def build_ntp():
    """Build/customize ntp configs"""

def build_k8s_yml():
    """Build kubernetes yml files for deployment"""

