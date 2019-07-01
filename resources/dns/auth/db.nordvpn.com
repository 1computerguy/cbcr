$TTL  86400
@       IN      SOA     ns1.nordvpn.com. dns-admin.nordvpn.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
nordvpn.com.      IN      A       106.18.229.229
nordvpn.com.     IN    NS    ac1.nstld.com.
nordvpn.com.     IN    NS    ac2.nstld.com.
nordvpn.com.     IN    NS    a.nic.dns-tld.site.
nordvpn.com.     IN    NS    b.nic.dns-tld.site.
