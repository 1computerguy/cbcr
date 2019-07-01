$TTL  86400
@       IN      SOA     ns1.facebook.com. dns-admin.facebook.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
facebook.com.      IN      A       31.13.65.36
www.facebook.com.     IN      CNAME       facebook.com.
smtpin.vvv.facebook.com.      IN      A       176.252.127.251
facebook.com.      IN      MX      10  smtpin.vvv.facebook.com.
facebook.com.     IN    NS    ac1.nstld.com.
facebook.com.     IN    NS    ac2.nstld.com.
facebook.com.     IN    NS    a.nic.dns-tld.site.
facebook.com.     IN    NS    b.nic.dns-tld.site.
