$TTL  86400
@       IN      SOA     ns1.privatevpn.com. dns-admin.privatevpn.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
privatevpn.com.      IN      A       196.24.4.13
privatevpn.com.     IN    NS    ac1.nstld.com.
privatevpn.com.     IN    NS    ac2.nstld.com.
privatevpn.com.     IN    NS    a.nic.dns-tld.site.
privatevpn.com.     IN    NS    b.nic.dns-tld.site.
