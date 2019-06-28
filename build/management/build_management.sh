#!/bin/bash

if [ "$(id -u)" == "0" ]; then
	echo "Please run this as a normal user, not root"
	exit 1
fi

usage() {
    echo ""
    echo "Use this script to build the backend management containers; NFS, Local Registry,"
    echo " and the Rancher manager (this one is for optional use, but can be quite helpful"
    echo " especially if you setup the Prometheus and Grafana logging for troubleshooting and"
    echo " monitoring cluster health and performance). If you anticipate this being a purely"
    echo " ephemeral range, then you don't have to worry about Rancher and it's logging."
    echo ""
    echo " ----"
    echo -e "    Example: $0"
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

echo "------------------------------------------------"
echo "Setting environment variables and making sure they persist..."
echo "------------------------------------------------"
echo ""
# Set Environment Variables for use with other scripts and environment validation
set -a
source .env
set +a

# Copy .env file to home directory for use with .bashrc to load variables on login
cp .env ~/.env

cat >> .bashrc <<ENV
set -a
    [ -f ~/.env ] && . ~/.env
set +a
ENV

echo "-----------------------------------------------"
echo "Building directory structure..."
echo "-----------------------------------------------"
echo ""
# Create default range directories
# TODO: Make this user configurable
sudo mkdir -p /range/{mgmt/{rancher,registry,pki/{root-ca,intermed-ca}},configs/{attack/{kali,metasploit},monitor/{bro,elastic,kibana,logstash},dns,web,ftp,media-svr,network,webmail,vuln/{metasploit-vuln,mutillidae,wordpress}}}
sudo chown -R $user:$user /range

echo "-----------------------------------------------"
echo "Generating cert for Docker Registry"
echo "-----------------------------------------------"
echo ""
registry_dir="$MGMT_HOME/registry"

openssl req  -newkey rsa:4096 -nodes -sha256 -keyout $registry_dir/domain.key  -x509 -days 365 -out $registry_dir/domain.crt -subj "/CN=master"
mkdir -p /etc/docker/certs.d/master:5000
cp $registry_dir/domain.crt /etc/docker/certs.d/master:5000/ca.crt

echo "-----------------------------------------------"
echo "Building PKI infrastructure..."
echo "-----------------------------------------------"
echo ""
pki/build_pki.sh

echo "-----------------------------------------------"
echo "Building and deploying Management Containers..."
echo "-----------------------------------------------"
echo ""
docker-compose build
docker-compose up

exit 0