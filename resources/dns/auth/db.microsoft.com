$TTL  86400
@       IN      SOA     ns1.microsoft.com. dns-admin.microsoft.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
microsoft.com.      IN      A       40.76.4.15
www.microsoft.com.     IN      CNAME       microsoft.com.
microsoft.com.     IN    NS    ac1.nstld.com.
microsoft.com.     IN    NS    ac2.nstld.com.
microsoft.com.     IN    NS    a.nic.dns-tld.site.
microsoft.com.     IN    NS    b.nic.dns-tld.site.
