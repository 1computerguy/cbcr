$TTL  86400
@       IN      SOA     ns1.google.com. dns-admin.google.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
google-public-dns-a.google.com.      IN      A       8.8.8.8
google-public-dns-b.google.com.      IN      A       8.8.4.4
google.com.      IN      A       172.217.0.78
www.google.com.     IN      CNAME       google.com.
aspmx.l.google.com.      IN      A       74.125.21.26
google.com.      IN      MX      10  aspmx.l.google.com.
google.com.     IN    NS    ac1.nstld.com.
google.com.     IN    NS    ac2.nstld.com.
google.com.     IN    NS    a.nic.dns-tld.site.
google.com.     IN    NS    b.nic.dns-tld.site.
