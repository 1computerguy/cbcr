$TTL  86400
@       IN      SOA     ns1.hackattack.com. dns-admin.hackattack.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
hackattack.com.      IN      A       102.120.3.42
www.hackattack.com.     IN      CNAME       hackattack.com.
hackattack.com.     IN    NS    ac1.nstld.com.
hackattack.com.     IN    NS    ac2.nstld.com.
hackattack.com.     IN    NS    a.nic.dns-tld.site.
hackattack.com.     IN    NS    b.nic.dns-tld.site.
