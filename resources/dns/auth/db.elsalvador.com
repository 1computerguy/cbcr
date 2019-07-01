$TTL  86400
@       IN      SOA     ns1.elsalvador.com. dns-admin.elsalvador.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
elsalvador.com.      IN      A       179.249.122.52
www.elsalvador.com.     IN      CNAME       elsalvador.com.
elsalvador.com.     IN    NS    ac1.nstld.com.
elsalvador.com.     IN    NS    ac2.nstld.com.
elsalvador.com.     IN    NS    a.nic.dns-tld.site.
elsalvador.com.     IN    NS    b.nic.dns-tld.site.
