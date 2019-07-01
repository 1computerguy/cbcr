$TTL  86400
@       IN      SOA     ns1.yandex.ru. dns-admin.yandex.ru. (
                        2019063002         ; Serial
                        604800         ; Refresh
                        86400         ; Retry
                        2419200         ; Expire
                        604800 )       ; Negative Cache TTL
yandex.ru.      IN      A       77.88.55.55
www.yandex.ru.     IN      CNAME       yandex.ru.
yandex.ru.     IN    NS    ac1.nstld.com.
yandex.ru.     IN    NS    ac2.nstld.com.
yandex.ru.     IN    NS    a.nic.dns-tld.site.
yandex.ru.     IN    NS    b.nic.dns-tld.site.
