#!/bin/bash

docker build -t master:5000/vunl-wordpress:latest .
docker push master:5000/vuln-wordpress:latest
docker rmi vulhub/httpd:bad-http

docker build -t master:5000/mysql:5 -f ./Dockerfile.mysql
docker push master:5000/mysql:5
docker rmi mysql:5