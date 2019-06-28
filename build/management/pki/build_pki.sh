#!/bin/bash

root_dir="$PKI_HOME/root-ca"
intermed_dir="$PKI_HOME/intermed-ca"
dom_name="range.com"
alt_dom_name="range.net"
start_date=`date +%y%m%d000000Z -u -d -1day`
end_date=`date +%y%m%d000000Z -u -d +10years+1day`

# Build base folder/file structure and set some permissions
mkdir -p {$root_dir,$intermed_dir}/{certreqs,certs,crl,newcerts,private}
chmod 700 {$root_dir,$intermed_dir}/private
touch $root_dir/{root-ca.index,root-ca.index.attr,root-ca.serial}
echo 00 > $root_dir/root-ca.crlnum
touch $intermed_dir/{intermed-ca.index,intermed-ca.index.attr,intermed-ca.serial}
echo 00 > $intermed_dir/intermed-ca.crlnum


sed "s|{{PKI_HOME}}|$PKI_HOME|g" root-config.cnf.tmpl | sed "s/{{DOM_NAME}}/$dom_name/g" | sed "s/{{ALT_DOM_NAME}}/$alt_dom_name/g" > $root_dir/root-ca.cnf

sed "s|{{PKI_HOME}}|$PKI_HOME|g" intermed-config.cnf.tmpl | sed "s/{{DOM_NAME}}/$dom_name/g" | sed "s/{{ALT_DOM_NAME}}/$alt_dom_name/g" > $intermed_dir/intermed-ca.cnf

# Setup Root CA
cd $root_dir
export OPENSSL_CONF=$root_dir/root-ca.cnf
# Generate secret passphrase that can be used to automate signing
openssl rand -base64 48 > .passphrase

# Generate initial Root CA Key
openssl req -new -passout file:.passphrase -out root-ca.req.pem

# Set permissions, and generate remaining Root keys
chmod 400 private/root-ca.key.pem
openssl req -new -passin file:.passphrase -key private/root-ca.key.pem -out root-ca.req.pem
openssl rand -hex 16 > root-ca.serial
expect -c "
spawn openssl ca -selfsign -in root-ca.req.pem -passin file:.passphrase -out root-ca.cert.pem -extensions root-ca_ext -startdate $start_date -enddate $end_date
expect \"ign the certificate\" {
  send \"y\r\"

  expect \"1 out of 1 certificate requests certified, commit\"
  send \"y\r\"
  exp_continue
  }
"

openssl ca -gencrl -passin file:.passphrase -out crl/root-ca.crl

# Setup Intermediate CA
cd $intermed_dir
export OPENSSL_CONF=$intermed_dir/intermed-ca.cnf

# Generate secret passphrase that can be used to automate signing
openssl rand -base64 48 > .passphrase

# Generate initial Root CA Key
openssl req -new -passout file:.passphrase -out intermed-ca.req.pem

chmod 400 private/intermed-ca.key.pem
openssl rand -hex 16 > intermed-ca.serial
openssl req -new -passin file:.passphrase -key private/intermed-ca.key.pem -out intermed-ca.req.pem
cp intermed-ca.req.pem $root_dir/certreqs

cd $root_dir
export OPENSSL_CONF=$root_dir/root-ca.cnf
openssl rand -hex 16 > root-ca.serial
expect -c "
spawn openssl ca -in certreqs/intermed-ca.req.pem -passin file:.passphrase -out certs/intermed-ca.cert.pem -extensions intermed-ca_ext -startdate $start_date -enddate $end_date
expect \"ign the certificate\" {
  send \"y\r\"

  expect \"1 out of 1 certificate requests certified, commit\"
  send \"y\r\"
  exp_continue
  }
"
cp certs/intermed-ca.cert.pem $intermed_dir/
cd $intermed_dir
export OPENSSL_CONF=$intermed_dir/intermed-ca.cnf
openssl ca -gencrl -passin file:.passphrase -out crl/intermed-ca.crl

exit 0
