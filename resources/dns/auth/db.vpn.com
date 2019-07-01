$TTL  86400
@       IN      SOA     ns1.vpn.com. dns-admin.vpn.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
vpn.com.      IN      A       34.202.89.42
vpn.com.     IN    NS    ac1.nstld.com.
vpn.com.     IN    NS    ac2.nstld.com.
vpn.com.     IN    NS    a.nic.dns-tld.site.
vpn.com.     IN    NS    b.nic.dns-tld.site.
