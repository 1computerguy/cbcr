#!/bin/bash
CA_DIR="/range-ca"
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
touch ${ROOT_DIR}/{root-ca.index,root-ca.index.attr}
echo 00 > ${ROOT_DIR}/root-ca.crlnum
touch ${INTERMED_DIR}/intermed-ca.index,intermed-ca.index.attr}
echo 00 > ${INTERMED_DIR}/intermed-ca.crlnum


sed "s/{{DOM_NAME}}/$DOM_NAME/g" root-config.cnf.tmpl | sed "s/{{ALT_DOM_NAME}}/$ALT_DOM_NAME/g" > $ROOT_DIR/root-ca.cnf

sed "s/{{DOM_NAME}}/$DOM_NAME/g" intermed-config.cnf.tmpl | sed "s/{{ALT_DOM_NAME}}/$ALT_DOM_NAME/g" > $INTERMED_DIR/intermed-ca.cnf

# Setup Root CA
cd $ROOT_DIR
export OPENSSL_CONF=./root-ca.cnf
expect <<EOC
  spawn openssl req -new -out root-ca.req.pem
  expect "Enter PEM pass phrase"
  send "${ROOT_PASS}\r"
  expect "Verifying - Enter PEM pass phrase"
  send "${ROOT_PASS}\r"

  spawn chmod 400 private/root-ca.key.pem

  spawn openssl req -new -key private/root-ca.key.pem -out root-ca.req.pem
  expect "Enter pass phrase for private"
  send "${ROOT_PASS}\r"

  spawn openssl rand -hex 16 > root-ca.serial

  spawn openssl ca -selfsign -in root-ca.req.pem -out root-ca.cert.pem -extensions root-ca_ext -startdate ${START_DATE} -enddate ${END_DATE}
  expect "Enter pass phrase for "
  send "${ROOT_PASS}\r"
  expect "Sign the certificate?"
  send "y\r"
  expect "1 out of 1 certificate requests certified, commit?"
  send "y\r"

  spawn openssl ca -gencrl -out crl/root-ca.crl
  expect "Enter pass phrase for "
  send "${ROOT_PASS}\r"
EOC

# Setup Intermediate CA
cd $INTERMED_DIR
export OPENSSL_CONF=./intermed-ca.cnf

expect <<EOC
  spawn  openssl req -new -out intermed-ca.req.pem
  expect "Enter PEM pass phrase"
  send "${INTERMED_PASS}\r"
  expect "Verifying - Enter PEM pass phrase"
  send "${INTERMED_PASS}\r"

  spawn chmod 400 private/intermed-ca.key.pem

  spawn openssl rand -hex 16 > intermed-ca.serial

  spawn openssl req -new -key private/intermed-ca.key.pem -out intermed-ca.req.pem
  expect "Enter pass phrase for private"
  send "${INTERMED_PASS}\r"

  spawn cp intermed-ca.req.pem ${ROOT_DIR}/certreqs
  spawn cd ${ROOT_DIR}
  spawn export OPENSSL_CONF=./root-ca.cnf
  spawn openssl rand -hex 16 > root-ca.serial

  spawn openssl ca -in certreqs/intermed-ca.req.pem -out certs/intermed-ca.cert.pem -extensions intermed-ca_ext -startdate ${START_DATE} -enddate ${END_DATE}
  expect "Enter pass phrase for "
  send "${ROOT_PASS}\r"
  expect "Sign the certificate? "
  send "y\r"
  expect "1 out of 1 certificate requests certified, commit? "
  send "y\r"
EOC

cp certs/intermed-ca.cert.pem $INTERMED_DIR/
cd $INTERMED_DIR
export OPENSSL_CONF=./intermed-ca.cnf

expect <<EOC
  spawn openssl ca -gencrl -out crl/intermed-ca.crl
  expect "Enter pass phrase for "
  send "${INTERMED_PASS}\r"
EOC

exit 0
