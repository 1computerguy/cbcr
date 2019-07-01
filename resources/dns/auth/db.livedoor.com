$TTL  86400
@       IN      SOA     ns1.livedoor.com. dns-admin.livedoor.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
livedoor.com.      IN      A       202.104.153.16
www.livedoor.com.     IN      CNAME       livedoor.com.
livedoor.com.     IN    NS    ac1.nstld.com.
livedoor.com.     IN    NS    ac2.nstld.com.
livedoor.com.     IN    NS    a.nic.dns-tld.site.
livedoor.com.     IN    NS    b.nic.dns-tld.site.
