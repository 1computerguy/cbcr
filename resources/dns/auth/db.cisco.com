$TTL  86400
@       IN      SOA     ns1.cisco.com. dns-admin.cisco.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
ftp.cisco.com.      IN      A       72.163.4.185
cisco.com.     IN    NS    ac1.nstld.com.
cisco.com.     IN    NS    ac2.nstld.com.
cisco.com.     IN    NS    a.nic.dns-tld.site.
cisco.com.     IN    NS    b.nic.dns-tld.site.
