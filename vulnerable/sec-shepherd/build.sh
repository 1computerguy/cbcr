#!/bin/bash

docker build -t master:5000/sec-shepherd:latest .
docker push master:5000/sec-shepherd:latest
docker rmi owasp/security-shepherd:latest

docker build -t master:5000/mysql:latest -f ./Dockerfile.mysql
docker push master:5000/mysql:latest
docker rmi mysql:latest