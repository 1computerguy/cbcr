$TTL  86400
@       IN      SOA     ns1.muteme.com. dns-admin.muteme.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
muteme.com.      IN      A       41.0.12.15
www.muteme.com.     IN      CNAME       muteme.com.
muteme.com.     IN    NS    ac1.nstld.com.
muteme.com.     IN    NS    ac2.nstld.com.
muteme.com.     IN    NS    a.nic.dns-tld.site.
muteme.com.     IN    NS    b.nic.dns-tld.site.
