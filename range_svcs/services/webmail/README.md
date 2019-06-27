# Poste.io - complete mailserver built in one container
Full stack mailserver solution with SSL TLS support. POP3s, SMTP(s), IMAPs, RSPAMD, Clamav, Roundcube(HTTPS), SPF, DKIM with simple installation and web administration.

- Pro version demo running at https://demo.poste.io/admin/login#admin@poste.io;admin
- For instructions how to install please see https://poste.io/doc/

### Native features
- Let's encrypt for free and automatic TLS certs!
- SMTP routing (redirects all outgoing emails to the smarthost)
- SRS (fix redirects to follow valid SPF)
- "From" header check to prevent sender spoofing within mailserver users (toggleable per user)
- Remove redundant headers and hide authenticated sender IP for privacy
- Inbound antispam&antivirus (outbound at PRO)
- Automated Trash and Junk folders cleaning
- Relay limits with optional blocking prevents cases when one of your users computer got infected and tries to spam (PRO)
- "Karma" for making spammers life harder and much slower (p0f for detecting senders system, dns/mx/reverse lookups, DNSBL)
- Blacklist&Whitelist + automatic blocking for resources wasters
- Quarantine folder inspectable through administration
- Whole domain forwarding
- Domain-bin aka catch-all address
- DKIM setup through administration
- Very detailed logs (searchable and viewable through administration PRO)
- DMARC reports (PRO)
- REST API and command line for emails and domains manipulation
- Server and domain DNS Diagnostics, DNSBL check
- Quota for users
- Levels of administration rights: system admin, domain admin(PRO) and user
- Default Sieve filters for redirect, copy, autoreply, out of office, custom

### Want more?
Look at demo! https://demo.poste.io/admin/login#admin@poste.io;admin

### I want one!
Please see https://poste.io