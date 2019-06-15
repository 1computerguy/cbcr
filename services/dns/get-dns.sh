#!/bin/bash

# Set folder dirs globally
record_dir="$BUILD_DIR/dns-records"
ip_dir="$BUILD_DIR/ip-records"

usage() {
  echo ""
  echo "--------------------------------------------------------------------------"
  echo "Please provide a domain to generate a Bind9 DB file for."
  echo ""
  echo -e "    -d :  Used for standard DNS record entries"
  echo -e "    -m | --mail : Used for email MX record entries for mail servers"
  echo ""
  echo "EXAMPLE: $0 -d amazon.com"
  echo ""
  exit
}


make_dns() {
  if [ "$2" == "mail" ]
  then

  elif [ "$2" != "" ]
    ip="$2"
  fi
  mkdir -p {$record_dir,$ip_dir}
  domain="$1"
  a_record=`dig $domain A | grep -v "TXT" | sed -n '/;; ANSWER/,/;; Query/{ /;;/d; p }' | awk 'FNR <= 1 {print $1"\t"$3"\t"$4"\t"$5" "$6}'`
  ip_addr=`awk -F$'\t' '{print $4}' <<< $a_record`

  cat > $record_dir/db.$domain <<EOF
$TTL  86400
@     `echo -n $(dig $domain SOA | grep -v "TXT" | sed -n '/;; ANSWER/,/;; Query/{ /;;/d; p }' | awk '{print $3"\t"$4"\t"$5" "$6}')` (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
$domain.     IN    NS    ns1.domain.cm
$domain.     IN    NS    ns2.domain.com
$a_record
EOF

  cat >> $record_dir/named.conf <<EOF
zone "$domain" {
      type master;
      file "/etc/bind/db.$domain";
};
EOF

  #echo -e "$domain,$ip_addr" >> $ip_dir/addresses.csv
}

if [ $# -gt 0 ]
then
  case $1 in
    -h | --help )
      usage
      ;; 
    -m | -mail )
      shift
      make_dns "$1" "mail" 
      ;;
    -d )
      shift
      make_dns "$1"
      ;;
    -s )
      shift
      make_dns "$1" "$2"
  esac


else
  usage
fi
