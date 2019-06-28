# PKI Root and Intermediate CA configuration.

These script files contain the commands necessary to build and configure a Root and Intermediate CA server for any SSL certs required for in-range services.

### NOTE: **Accurate as of 14 June 2019** For some reason, the the "sign-cert.sh" script ONLY works properly when the commands within it are run from the command line directly (NOT as a script...). When these are run as a part of a shell script, they fail to sign the certs and do not function.

This block of code is in the top of the sign-cert.sh script.

```
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
```