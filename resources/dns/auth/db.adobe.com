$TTL  86400
@       IN      SOA     ns1.adobe.com. dns-admin.adobe.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
ftp.adobe.com.      IN      A       193.104.215.58
adobe.com.     IN    NS    ac1.nstld.com.
adobe.com.     IN    NS    ac2.nstld.com.
adobe.com.     IN    NS    a.nic.dns-tld.site.
adobe.com.     IN    NS    b.nic.dns-tld.site.
