#!/bin/bash

docker build -t master:5000/metasploit:latest .
docker push master:5000/metasploit:latest
docker rmi metasploitframework/metasploit-framework:latest