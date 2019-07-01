$TTL  86400
@       IN      SOA     ns1.email.com. dns-admin.email.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
mail.email.com.      IN      A       68.178.213.60
email.com.      IN      MX      10  mail.email.com.
email.com.     IN    NS    ac1.nstld.com.
email.com.     IN    NS    ac2.nstld.com.
email.com.     IN    NS    a.nic.dns-tld.site.
email.com.     IN    NS    b.nic.dns-tld.site.
