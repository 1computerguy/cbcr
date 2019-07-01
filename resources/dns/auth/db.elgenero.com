$TTL  86400
@       IN      SOA     ns1.elgenero.com. dns-admin.elgenero.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
elgenero.com.      IN      A       201.23.113.243
www.elgenero.com.     IN      CNAME       elgenero.com.
elgenero.com.     IN    NS    ac1.nstld.com.
elgenero.com.     IN    NS    ac2.nstld.com.
elgenero.com.     IN    NS    a.nic.dns-tld.site.
elgenero.com.     IN    NS    b.nic.dns-tld.site.
