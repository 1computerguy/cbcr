$TTL  86400
@       IN      SOA     ns1.fakaza.com. dns-admin.fakaza.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
fakaza.com.      IN      A       154.162.225.76
www.fakaza.com.     IN      CNAME       fakaza.com.
fakaza.com.     IN    NS    ac1.nstld.com.
fakaza.com.     IN    NS    ac2.nstld.com.
fakaza.com.     IN    NS    a.nic.dns-tld.site.
fakaza.com.     IN    NS    b.nic.dns-tld.site.
