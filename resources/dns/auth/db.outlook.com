$TTL  86400
@       IN      SOA     ns1.outlook.com. dns-admin.outlook.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
microsoft-com.mail.protection.outlook.com.      IN      A       104.47.54.36
outlook.com.      IN      MX      10  microsoft-com.mail.protection.outlook.com.
outlook.com.     IN    NS    ac1.nstld.com.
outlook.com.     IN    NS    ac2.nstld.com.
outlook.com.     IN    NS    a.nic.dns-tld.site.
outlook.com.     IN    NS    b.nic.dns-tld.site.
