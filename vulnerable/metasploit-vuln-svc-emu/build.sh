#!/bin/bash

docker build -t master:5000/metasploit-vuln-svc-emu:latest .
docker push master:5000/metasploit-vuln-svc-emu:latest
docker rmi vulnerables/metasploit-vulnerability-emulator:latest
