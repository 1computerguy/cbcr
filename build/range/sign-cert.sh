#!/bin/bash

usage() {
  echo ""
  echo "------------------------------------------------------------------------"
  echo " This script uses a Range generated PKI to sign domains for Range use"
  echo " It accepts 3 different inputs:"
  echo -e "     - Single domain <-s domain.com>"
  echo -e "     - List of domains <-l domain1.com domain2.net domain3.org>"
  echo -e "     - Newline delimted file list of domains <-f filename.txt>"
  echo ""
  echo " Example Usage:"
  echo -e "    $0 -s domain.com"
  echo -e "    $0 -l domain1.com domain2.net"
  echo -e "    $0 -f domainlist.txt"
  echo ""
  exit 1
}

sign-cert() {
  local ca_dir="$PKI_HOME/intermed-ca"
  local web_dir="$CONFIG_HOME/web"
  local domain="$1"
  local dom_ssl_dir="$web_dir/$domain/ssl"

  mkdir -p $dom_ssl_dir

  cd "$ca_dir"
  export OPENSSL_CONF="./intermed-ca.cnf"

  openssl req -new -passin file:.passphrase -newkey rsa:2048 -nodes -keyout "$dom_ssl_dir/server-key.pem" -out certreqs/$domain.csr -subj "/C=US/ST=Georgia/O=Ranges-R-Us, Inc./CN=$domain"
  openssl rand -hex 16 > intermed-ca.serial
  expect -c "
    spawn openssl ca -passin file:.passphrase -in certreqs/${domain}.csr -out certs/${domain}.cert.pem -extensions server_ext
    expect \"Sign the certificate\" {
    send \"y\r\"

    expect \"1 out of 1 certificate requests certified\"
    send \"y\r\"
    exp_continue
    }
  "
  cp "$ca_dir/certs/$domain.cert.pem" "$dom_ssl_dir/server.pem"
}

if [ $# -gt 1 ]
then
  case $1 in
    # Process newline delimited file of domains
    -f | --file )
      shift
      while read dom
      do
        sign-cert "$dom"
      done < "$1"
      ;;
    # Process single domain
    -s | --site )
      shift
      sign-cert "$1"
      ;;
    # Process list of domains from CLI
    -l | --list )
      shift
      while [ "$1" != "" ]
      do
        sign-cert "$1"
        shift
      done
      ;;
    -h | --help )
      usage
      ;;
  esac
else
  usage
fi

exit 0
