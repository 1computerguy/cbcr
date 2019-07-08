#!/bin/bash

set -e

if [ "$(id -u)" == "0" ]; then
	echo "Please run this as a normal user, not root"
	exit 1
fi

source ~/.env

usage() {
    echo ""
    echo "Use this script to build the backend management containers; NFS, Local Registry,"
    echo " and the Rancher manager (this one is for optional use, but can be quite helpful"
    echo " especially if you setup the Prometheus and Grafana logging for troubleshooting and"
    echo " monitoring cluster health and performance). If you anticipate this being a purely"
    echo " ephemeral range, then you don't have to worry about Rancher and it's logging."
    echo ""
    echo " ----"
    echo -e "    Example: $0 -u <username>"
    echo " ----"
    echo ""
    echo ""
}

# Set arguments as variables
if [ $# -gt 1 ]
then
    count=0
    while [ "$1" != "" ]
    do
        case $1 in
            -u | --username )
                shift
                user="$1"
                ;;
            -h | --help )
                usage
                exit
                ;;
            * )
                usage
                exit 1
                ;;
        esac
        shift
    done
else
    usage
    exit 1
fi


echo "-----------------------------------------------"
echo "Building directory structure..."
echo "-----------------------------------------------"
echo ""
# Create default range directories
# TODO: Make this user configurable
sudo mkdir -p /range/{mgmt/{rancher,registry,pki/{root-ca,intermed-ca}},configs}
sudo mkdir -p /range/configs/attack/{rtr1-attacker,rtr2-attacker,rtr3-attacker,rtr4-attacker,rtr5-attacker,rtr6-attacker}
sudo mkdir -p /range/configs/smtp/webmail
sudo mkdir -p /range/configs/ftp/{ftp.adobe.com,ftp.cisco.com,ftp.malwr.cn,ftp.music.ru}
sudo mkdir -p /range/configs/{web,ftp,media-svr,network,webmail}
sudo mkdir -p /range/configs/vuln/{metasploit-vuln,mutillidae,wordpress}

sudo cp -r $REPO_HOME/resources/dns $RANGE_HOME/configs/
sudo cp -r $REPO_HOME/resources/monitor $RANGE_HOME/configs/

sudo mkdir -p $RANGE_HOME/configs/network
sudo cp -r $REPO_HOME/resources/router-configs/* $RANGE_HOME/configs/network

sudo chown -R $user:$user /range

echo "-----------------------------------------------"
echo "Generating cert for Docker Registry"
echo "-----------------------------------------------"
echo ""
registry_dir="$MGMT_HOME/registry"

openssl req  -newkey rsa:4096 -nodes -sha256 -keyout $registry_dir/domain.key  -x509 -days 365 -out $registry_dir/domain.crt -subj "/CN=master"
sudo mkdir -p /etc/docker/certs.d/master:5000
sudo cp $registry_dir/domain.crt /etc/docker/certs.d/master:5000/ca.crt

echo "-----------------------------------------------"
echo "Building PKI infrastructure..."
echo "-----------------------------------------------"
echo ""
cd pki
./build_pki.sh

cd ../
echo "-----------------------------------------------"
echo "Building and deploying Management Containers..."
echo "-----------------------------------------------"
echo ""
docker-compose up -d    

exit 0