$TTL  86400
@       IN      SOA     ns1.ausvpn.com. dns-admin.ausvpn.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
ausvpn.com.      IN      A       150.1.79.230
ausvpn.com.     IN    NS    ac1.nstld.com.
ausvpn.com.     IN    NS    ac2.nstld.com.
ausvpn.com.     IN    NS    a.nic.dns-tld.site.
ausvpn.com.     IN    NS    b.nic.dns-tld.site.
