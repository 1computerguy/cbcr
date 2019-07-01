$TTL  86400
@       IN      SOA     ns1.nstld.com. dns-admin.nstld.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
ac1.nstld.com.      IN      A       192.42.173.30
ac2.nstld.com.      IN      A       192.42.174.30
nstld.com.     IN    NS    ac1.nstld.com.
nstld.com.     IN    NS    ac2.nstld.com.
nstld.com.     IN    NS    a.nic.dns-tld.site.
nstld.com.     IN    NS    b.nic.dns-tld.site.
