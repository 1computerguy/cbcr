#!/bin/bash

docker build -t master:5000/metasploit:latest .
docker push master:5000/metasploit:latest
docker rmi metasploitframework/metasploit-framework:latest

docker pull postgres:10-alpine
docker tag postgres:10-alpine master:5000/postgres:latest
docker push master:5000/postgres:latest
docker rmi postgres:10-alpine
