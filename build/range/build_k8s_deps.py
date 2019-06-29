#!/usr/bin/python3

import csv
import os
import glob
import sys
from shutil import copyfile, copytree
import ipaddress

svc_cfg_file = "range_services.csv"
net_cfg_file = "range_network.csv"

def build_web(web_svcs):
    # Generate kuku command and call using os.system()
    volume_name = web_svcs["domain_name"].replace('.', '-')
    command = ''

    command = 'kuku render -s name={name},'.format(name=web_svcs["k8s_name"])
    command += 'image=master:5000/{cont},replicas=1,'.format(cont=web_svcs["container_name"])
    command += 'env="IP_ADDR LEN GATEWAY INT",'
    command += 'vals="{addr} {len} {gw} {nic}",'.format(addr=web_svcs["ip_address"],
                                                        len=web_svcs["cidr_len"],
                                                        gw=web_svcs["gateway"],
                                                        nic=web_svcs["nic"])
    command += 'netkey=k8s.v1.cni.cncf.io/networks,'
    command += 'netval={bridge}'.format(bridge=web_svcs["svc_bridge"])

    if web_svcs["container_name"] == "nginx":
        mount_path = "/usr/share/nginx/html"
        nfs_path = os.environ["CONFIG_HOME"] + "/web/" + web_svcs["domain_name"]
        
        command += ',volumeName={volume},'.format(volume=volume_name)
        command += 'mountPath={mount},'.format(mount=mount_path)
        command += 'nfsPath={nfs},'.format(nfs=nfs_path)
        command += 'nfsServer=storage'

    elif web_svcs["container_name"] == "media":
        mount_path = "/media/serviio"
        nfs_path = os.environ["CONFIG_HOME"] + "/media/" + web_svcs["domain_name"]

        command += ',volumeName={volume},'.format(volume=volume_name)
        command += 'mountPath={mount},'.format(mount=mount_path)
        command += 'nfsPath={nfs},'.format(nfs=nfs_path)
        command += 'nfsServer=storage'

    return command


def build_dns(dns_svcs):
    """Build K8s DNS deployment yaml files"""
    # Generate kuku command and call using os.system()
    volume_name = dns_svcs["domain_name"].replace('.', '-')
    command = ''
    mount_path = "/etc/bind"

    if dns_svcs["svc_sub_type"] == "authoritative":
        nfs_path = os.environ["CONFIG_HOME"] + "/dns/auth"
    elif dns_svcs["svc_sub_type"] == "root":
        nfs_path = os.environ["CONFIG_HOME"] + "/dns/root"
    elif dns_svcs["svc_sub_type"] == "recursive":
        nfs_path = os.environ["CONFIG_HOME"] + "/dns/recursive"

    command = 'kuku render -s name={name},'.format(name=dns_svcs["k8s_name"])
    command += 'image=master:5000/{cont},replicas=1,'.format(cont=dns_svcs["container_name"])
    command += 'env="IP_ADDR LEN GATEWAY INT",'
    command += 'vals="{addr} {len} {gw} {nic}",'.format(addr=dns_svcs["ip_address"],
                                                        len=dns_svcs["cidr_len"],
                                                        gw=dns_svcs["gateway"],
                                                        nic=dns_svcs["nic"])
    command += 'netkey=k8s.v1.cni.cncf.io/networks,'
    command += 'netval={bridge},'.format(bridge=dns_svcs["svc_bridge"])
    command += 'volumeName={volume},'.format(volume=volume_name)
    command += 'mountPath={mount},'.format(mount=mount_path)
    command += 'nfsPath={nfs},'.format(nfs=nfs_path)
    command += 'nfsServer=storage'

    return command

def build_smtp(smtp_svcs):
    """Build K8s SMTP deployment yaml files"""
    # Generate kuku command and call using os.system()
    volume_name = ''
    nfs_path = ''
    mount_path = ''
    command = ''

    command = 'kuku render -s name={name},'.format(name=smtp_svcs["k8s_name"])
    command += 'image=master:5000/{cont},replicas=1,'.format(cont=smtp_svcs["container_name"])
    command += 'env="IP_ADDR LEN GATEWAY INT",'
    command += 'vals="{addr} {len} {gw} {nic}",'.format(addr=smtp_svcs["ip_address"],
                                                        len=smtp_svcs["cidr_len"],
                                                        gw=smtp_svcs["gateway"],
                                                        nic=smtp_svcs["nic"])
    command += 'netkey=k8s.v1.cni.cncf.io/networks,'
    command += 'netval={bridge}'.format(bridge=smtp_svcs["svc_bridge"])

    if smtp_svcs["svc_sub_type"] == "webmail":
        volume_name = smtp_svcs["domain_name"].replace('.', '-')
        mount_path = "/data"
        nfs_path = os.environ["CONFIG_HOME"] + "/smtp/webmail"

        command += ',volumeName={volume},'.format(volume=volume_name)
        command += 'mountPath={mount},'.format(mount=mount_path)
        command += 'nfsPath={nfs},'.format(nfs=nfs_path)
        command += 'nfsServer=storage'

    return command

def build_ntp(ntp_svcs):
    """Build K8s NTP deployment yaml files"""
    # Generate kuku command and call using os.system()

    command = 'kuku render -s name={name},'.format(name=ntp_svcs["k8s_name"])
    command += 'image=master:5000/{cont},replicas=1,'.format(cont=ntp_svcs["container_name"])
    command += 'env="IP_ADDR LEN GATEWAY INT",'
    command += 'vals="{addr} {len} {gw} {nic}",'.format(addr=ntp_svcs["ip_address"],
                                                        len=ntp_svcs["cidr_len"],
                                                        gw=ntp_svcs["gateway"],
                                                        nic=ntp_svcs["nic"])
    command += 'netkey=k8s.v1.cni.cncf.io/networks,'
    command += 'netval={bridge}'.format(bridge=ntp_svcs["svc_bridge"])

    return command

def build_vpn(vpn_svcs):
    """Build K8s VPN deployment yaml files"""
    # Generate kuku command and call using os.system()
    volume_name = vpn_svcs["domain_name"].replace('.', '-')
    command = ''
    mount_path = "/etc/openvpn"
    vpn_user = vpn_svcs["domain_name"].split('.')[0]
    key_path = os.environ["CONFIG_HOME"] + "/vpn"
    nfs_path = key_path + "/" + vpn_svcs["domain_name"]

    command = 'kuku render -s name={name},'.format(name=vpn_svcs["k8s_name"])
    command += 'image=master:5000/{cont},replicas=1,'.format(cont=vpn_svcs["container_name"])
    command += 'env="IP_ADDR LEN GATEWAY INT",'
    command += 'vals="{addr} {len} {gw} {nic}",'.format(addr=vpn_svcs["ip_address"],
                                                        len=vpn_svcs["cidr_len"],
                                                        gw=vpn_svcs["gateway"],
                                                        nic=vpn_svcs["nic"])
    command += 'netkey=k8s.v1.cni.cncf.io/networks,'
    command += 'netval={bridge},'.format(bridge=vpn_svcs["svc_bridge"])
    command += 'volumeName={volume},'.format(volume=volume_name)
    command += 'mountPath={mount},'.format(mount=mount_path)
    command += 'nfsPath={nfs},'.format(nfs=nfs_path)
    command += 'nfsServer=storage,'
    command += 'vpn_init="{usr}-genconfig {usr}-initpki {usr}-build-client {usr}-get-client",'.format(usr=vpn_user)
    command += 'vpn_cmds=" ovpn_genconfig -u udp://{domain}; ovpn_initpki nopass;'.format(domain=vpn_svcs["domain_name"])
    command += ' easyrsa build-client-full {usr} nopass; ovpn_getclient'.format(usr=vpn_user)
    command += ' {usr} > {kpath}/{usr}.ovpn"'.format(usr=vpn_user,kpath=key_path)

    return command

def build_ftp(ftp_svcs):
    """Build K8s ftp deployment yaml files"""
    # Generate kuku command and call using os.system()
    volume_name = ftp_svcs["domain_name"].replace('.', '-')
    command = ''
    mount_path = "/home/ftpuser"
    user = "ftpuser"
    passwd = "ftp123"
    nfs_path = os.environ["CONFIG_HOME"] + "/ftp/" + ftp_svcs["domain_name"]

    command = 'kuku render -s name={name},'.format(name=ftp_svcs["k8s_name"])
    command += 'image=master:5000/{cont},replicas=1,'.format(cont=ftp_svcs["container_name"])
    command += 'env="IP_ADDR LEN GATEWAY INT PUBLICHOST FTP_USER_NAME FTP_USER_PASS FTP_USER_HOME",'
    command += 'vals="{addr} {len} {gw} {nic} {host} {user} {passwd} {home}",'.format(addr=ftp_svcs["ip_address"],
                                                        len=ftp_svcs["cidr_len"],
                                                        gw=ftp_svcs["gateway"],
                                                        nic=ftp_svcs["nic"],
                                                        host=ftp_svcs["domain_name"],
                                                        user=user,
                                                        passwd=passwd,
                                                        home=mount_path)
    command += 'netkey=k8s.v1.cni.cncf.io/networks,'
    command += 'netval={bridge},'.format(bridge=ftp_svcs["svc_bridge"])
    command += 'volumeName={volume},'.format(volume=volume_name)
    command += 'mountPath={mount},'.format(mount=mount_path)
    command += 'nfsPath={nfs},'.format(nfs=nfs_path)
    command += 'nfsServer=storage'

    return command

def build_attack(attack_svcs):
    """Build K8s attack deployment yaml files"""
    # Generate kuku command and call using os.system()
    volume_name = attack_svcs["domain_name"].replace('.', '-')
    command = ''
    nfs_path = os.environ["CONFIG_HOME"] + "/attack/" + attack_svcs["domain_name"]
    
    if attack_svcs["svc_sub_type"] == "metasploit":
        mount_path = "/home/msf/.msf4"
    elif attack_svcs["svc_sub_type"] == "kali":
        mount_path = "/root"    

    command = 'kuku render -s name={name},'.format(name=attack_svcs["k8s_name"])
    command += 'image=master:5000/{cont},replicas=1,'.format(cont=attack_svcs["container_name"])
    command += 'env="IP_ADDR LEN GATEWAY INT",'
    command += 'vals="{addr} {len} {gw} {nic}",'.format(addr=attack_svcs["ip_address"],
                                                        len=attack_svcs["cidr_len"],
                                                        gw=attack_svcs["gateway"],
                                                        nic=attack_svcs["nic"])
    command += 'netkey=k8s.v1.cni.cncf.io/networks,'
    command += 'netval={bridge},'.format(bridge=attack_svcs["svc_bridge"])
    command += 'volumeName={volume},'.format(volume=volume_name)
    command += 'mountPath={mount},'.format(mount=mount_path)
    command += 'nfsPath={nfs},'.format(nfs=nfs_path)
    command += 'nfsServer=storage'

    return command

def build_network(network_svcs):
    """Build K8s network router deployment yaml files"""
    # Generate kuku command and call using os.system()
    volume_name = network_svcs["k8s_name"]
    command = ''
    nfs_path = os.environ["CONFIG_HOME"] + "/network/" + network_svcs["k8s_name"]
    mount_path = '/etc/frr'

    command = 'kuku render -s name={name},'.format(name=network_svcs["k8s_name"])
    command += 'image=master:5000/{cont},replicas=1,'.format(cont=network_svcs["container_name"])
    command += 'netkey=k8s.v1.cni.cncf.io/networks,'
    command += 'netval={bridge},'.format(bridge=network_svcs["networks"])
    command += 'volumeName={volume},'.format(volume=volume_name)
    command += 'mountPath={mount},'.format(mount=mount_path)
    command += 'nfsPath={nfs},'.format(nfs=nfs_path)
    command += 'nfsServer=storage'

    return command

services_reader = csv.reader(open(svc_cfg_file))
cidr = "24"
default_nic = "net1"

svc_data = {}
# Parse range_services.csv file and generate K8s deployment files for services
for row in services_reader:
    if row[0] != 'svc_category':
        svc_data[row[4]] = {"svc_bridge":row[3],
                        "svc_sub_type":row[5],
                        "k8s_name":row[7],
                        "ip_address":row[2],
                        "domain_name":row[1],
                        "container_name":row[8],
                        "cidr_len":cidr,
                        "gateway":str(ipaddress.ip_network(row[2] + "/" + cidr,strict=False)[1]),
                        "nic": default_nic}

        if row[4] == "web":
            os.system(build_web(svc_data[row[4]]) + " $TEMPLATE_DIR > $K8S_CONFIGS/" + svc_data[row[4]]["k8s_name"] + ".yml")

        elif row[4] == "dns":
            os.system(build_dns(svc_data[row[4]]) + " $TEMPLATE_DIR > $K8S_CONFIGS/" + svc_data[row[4]]["k8s_name"] + ".yml")

        elif row[4] == "smtp":
            os.system(build_smtp(svc_data[row[4]]) + " $TEMPLATE_DIR > $K8S_CONFIGS/" + svc_data[row[4]]["k8s_name"] + ".yml")

        elif row[4] == "ntp":
            os.system(build_ntp(svc_data[row[4]]) + " $TEMPLATE_DIR > $K8S_CONFIGS/" + svc_data[row[4]]["k8s_name"] + ".yml")

        elif row[4] == "vpn":
            os.system(build_vpn(svc_data[row[4]]) + " $TEMPLATE_DIR > $K8S_CONFIGS/" + svc_data[row[4]]["k8s_name"] + ".yml")
            
        elif row[4] == "ftp":
            os.system(build_ftp(svc_data[row[4]]) + " $TEMPLATE_DIR > $K8S_CONFIGS/" + svc_data[row[4]]["k8s_name"] + ".yml")

        elif row[4] == "attack":
            os.system(build_attack(svc_data[row[4]]) + " $TEMPLATE_DIR > $K8S_CONFIGS/" + svc_data[row[4]]["k8s_name"] + ".yml")

network_reader = csv.reader(open(net_cfg_file))
net_data = {}
# Parse range_network.csv file and generate K8s deployment files for routers
for row in network_reader:
    # Set/Reset ovs_bridge list each iteration
    ovs_bridge = []
    
    # Skip header row
    if row[0] != "k8s_pod_name":
        # Count number of BGP AS's in row[4] and append that many bgp links to router
        for x in range(len(str(row[4]).split(','))):
            ovs_bridge.append(row[1])

        # Append service and external links to router definition
        ovs_bridge.append(row[5])
        ovs_bridge.append(row[7])
        
        net_data["k8s_name"] = row[0]
        net_data["container_name"] = "frr"
        net_data["networks"] = "'" + ' '.join(ovs_bridge) + "'"

        os.system(build_network(net_data) + " $TEMPLATE_DIR > $K8S_CONFIGS/" + net_data["k8s_name"] + ".yml")
