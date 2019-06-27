#!/bin/bash

###########################################################################
#
# HAVE TO RUN THIS FROM CLI - DOES NOT WORK RIGHT WHEN RUN FROM SCRIPT...
# WILL CONTINUE TO DEBUG, BUT FOR NOW, JUST COPY AND PASTE THE BELOW SCRIPT
# DIRECTLY INTO THE CONSOLE.
# Change the INTERMED_CA_DIR and WEB_DIR variables to match your environment. If you
# ran the "range config" command, then these are already configured as environment
# variables and you do not need to set them again.

  INTERMED_CA_DIR="/range/infrastructure/pki/intermed-ca"
  WEB_DIR="/range/environment/web"
  ssl_conf="$INTERMED_CA_DIR/intermed-ca.cnf"
  
  export OPENSSL_CONF="$ssl_conf"
  readarray -t doms < ../scrape/default-sites

  for domain in ${doms[@]}
  do
    openssl req -new -newkey rsa:2048 -nodes -keyout "$WEB_DIR/$domain/server-key.pem" -out $INTERMED_CA_DIR/certreqs/$domain.csr -subj "/C=US/ST=Georgia/O=Ranges-R-Us, Inc./CN=$domain"
    openssl rand -hex 16 > $INTERMED_CA_DIR/intermed-ca.serial
    openssl ca -in $INTERMED_CA_DIR/certreqs/$domain.csr -out $INTERMED_CA_DIR/certs/$domain.cert.pem -extensions server_ext
    cp "$INTERMED_CA_DIR/certs/$domain.cert.pem" "$WEB_DIR/$domain/server.pem"
  done
#
###########################################################################

usage() {
  echo ""
  echo "--------------------------------------------------------------------------------------------"
  echo "*                                          DO STUFF                                        *"
  echo ""
  echo ""
  exit 1
}

sign-cert() {
  local CA_DIR="/range-ca/intermed-ca"
  local WEB_DIR="/range-content/web"
  local DOMAIN="$1"
  local SSL_CONF="intermed-ca.cnf"

  if [ ! -d "$WEB_DIR" ]
  then
    mkdir "$WEB_DIR"
  fi
  if [ ! -d "$WEB_DIR/$DOMAIN" ]
  then
    mkdir "$WEB_DIR/$DOMAIN"
  fi

  cd "$CA_DIR"
  export OPENSSL_CONF="./$SSL_CONF"

  openssl req -new -newkey rsa:2048 -nodes -keyout "$WEB_DIR/$DOMAIN/server.key" -out certreqs/$DOMAIN.csr -subj "/C=US/ST=Georgia/O=Ranges-R-Us, Inc./CN=$DOMAIN"
  openssl rand -hex 16 > intermed-ca.serial
  expect -c "
    spawn openssl ca -in certreqs/${DOMAIN}.csr -out certs/${DOMAIN}.cert.pem -extensions server_ext
    expect 'Sign the certificate'
    send 'y'
    expect '1 out of 1 certificate requests certified, commit'
    send 'y'
  "
  cp "$ca_dir/certs/$domain.cert.pem" "$web_dir/$domain/server.crt"
}

if [ $# -gt 1 ]
then
  while [ "$1" != "" ]
  do
    case $1 in
      -f | --file )
        shift
	whiel read dom
	do
	  sign-cert "$dom"
	done < "$1"
	;;
      -s | --site )
	shift
	sign-cert "$1"
	;;
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
  done
else
  usage
fi

exit 0
