#!/bin/bash

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
  cp "certs/${DOMAIN}.cert.pem" "${WEB_DIR}/${DOMAIN}/server.crt"
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
