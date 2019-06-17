import dns.rdataset
import dns.zone

zone = dns.zone.Zone(dns.name.from_text('example.com'))
all_data = (
    ('example.com.', 'SOA', ('davebeast.beast.local. david.beast.local. 2016031421 10800 3600 604800 21600',)),
    ('@', 'TXT', ('foo',)),
    ('@', 'MX', (10, 'mail')),
    ('@', 'A', ('1.2.3.4',)),
    ('mail', 'A', ('1.2.3.10',)),
)
for name, rtype, data in all_data:
  print name, rtype, data
  rdtype = dns.rdatatype.from_text(rtype)
  stuff = '\t\t'.join([str(x) for x in data])
  rdata = dns.rdata.from_text(dns.rdataclass.IN, rdtype, stuff)
  n = zone.get_rdataset(name, rdtype, create=True).add(rdata, 86400)

zone.to_file("db.example.com", sorted=True, relativize=False)
