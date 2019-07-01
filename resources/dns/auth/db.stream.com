$TTL  86400
@       IN      SOA     ns1.stream.com. dns-admin.stream.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
stream.com.      IN      A       184.29.214.127
www.stream.com.     IN      CNAME       stream.com.
stream.com.     IN    NS    ac1.nstld.com.
stream.com.     IN    NS    ac2.nstld.com.
stream.com.     IN    NS    a.nic.dns-tld.site.
stream.com.     IN    NS    b.nic.dns-tld.site.
