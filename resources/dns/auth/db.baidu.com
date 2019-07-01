$TTL  86400
@       IN      SOA     ns1.baidu.com. dns-admin.baidu.com. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
baidu.com.      IN      A       123.125.114.144
www.baidu.com.     IN      CNAME       baidu.com.
mx.maillb.baidu.com.      IN      A       12.0.243.41
baidu.com.      IN      MX      10  mx.maillb.baidu.com.
baidu.com.     IN    NS    ac1.nstld.com.
baidu.com.     IN    NS    ac2.nstld.com.
baidu.com.     IN    NS    a.nic.dns-tld.site.
baidu.com.     IN    NS    b.nic.dns-tld.site.
