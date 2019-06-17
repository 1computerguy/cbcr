#!/bin/bash
CA_DIR="/range/infrastructure/pki"
ROOT_DIR="${CA_DIR}/root-ca"
INTERMED_DIR="${CA_DIR}/intermed-ca"
ROOT_PASS="rootca"
INTERMED_PASS="intermedca"
DOM_NAME="range.com"
ALT_DOM_NAME="range.net"
START_DATE=`date +%y%m%d000000Z -u -d -1day`
END_DATE=`date +%y%m%d000000Z -u -d +10years+1day`

# Build base folder/file structure and set some permissions
mkdir -p {$ROOT_DIR,$INTERMED_DIR}/{certreqs,certs,crl,newcerts,private}
chmod 700 {$ROOT_DIR,$INTERMED_DIR}/private
touch ${ROOT_DIR}/{root-ca.index,root-ca.index.attr,root-ca.serial}
echo 00 > ${ROOT_DIR}/root-ca.crlnum
touch ${INTERMED_DIR}/{intermed-ca.index,intermed-ca.index.attr,intermed-ca.serial}
echo 00 > ${INTERMED_DIR}/intermed-ca.crlnum


sed "s/{{DOM_NAME}}/$DOM_NAME/g" root-config.cnf.tmpl | sed "s/{{ALT_DOM_NAME}}/$ALT_DOM_NAME/g" > $ROOT_DIR/root-ca.cnf

sed "s/{{DOM_NAME}}/$DOM_NAME/g" intermed-config.cnf.tmpl | sed "s/{{ALT_DOM_NAME}}/$ALT_DOM_NAME/g" > $INTERMED_DIR/intermed-ca.cnf

# Setup Root CA
cd $ROOT_DIR
export OPENSSL_CONF=$ROOT_DIR/root-ca.cnf

openssl req -new -out root-ca.req.pem

chmod 400 private/root-ca.key.pem
openssl req -new -key private/root-ca.key.pem -out root-ca.req.pem
openssl rand -hex 16 > root-ca.serial
openssl ca -selfsign -in root-ca.req.pem -out root-ca.cert.pem -extensions root-ca_ext -startdate $START_DATE -enddate $END_DATE
openssl ca -gencrl -out crl/root-ca.crl


# Setup Intermediate CA
cd $INTERMED_DIR
export OPENSSL_CONF=$INTERMED_DIR/intermed-ca.cnf

openssl req -new -out intermed-ca.req.pem
chmod 400 private/intermed-ca.key.pem
openssl rand -hex 16 > intermed-ca.serial
openssl req -new -key private/intermed-ca.key.pem -out intermed-ca.req.pem
cp intermed-ca.req.pem $ROOT_DIR/certreqs
cd $ROOT_DIR
export OPENSSL_CONF=$ROOT_DIR/root-ca.cnf
openssl rand -hex 16 > root-ca.serial
openssl ca -in certreqs/intermed-ca.req.pem -out certs/intermed-ca.cert.pem -extensions intermed-ca_ext -startdate $START_DATE -enddate $END_DATE

cp certs/intermed-ca.cert.pem $INTERMED_DIR/
cd $INTERMED_DIR
export OPENSSL_CONF=$INTERMED_DIR/intermed-ca.cnf
openssl ca -gencrl -out crl/intermed-ca.crl

exit 0
