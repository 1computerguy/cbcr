# Vulnerable services ready for exploitation

The services in this folder are used to place intentionally vulnerable services in the network so that the monitoring platforms can capture attack traffic for analysis. These can be attacked using the existing Metasploit and Kali containers in the default environment build, or you can use your own Kali system (physical or virtual) to attack the various platforms.

If all you are looking for are containerized vulnerable systems, I would recommend vulhub (https://github.com/vulhub/vulhub) - no typo, it's not vulnhub, that's for vulnerable VMs, these are all containers. This repo has an ever-growing library of vulnerable services, sites, and systems and can be deployed using docker-compose instead of worrying about the additional overhead of this cluster and it's network stack.

If you have your own vulnerable services you would like to see added to this range, feel free to messag me, submit an "Issue", or just let me know and I'll see what I can do to get it integrated.