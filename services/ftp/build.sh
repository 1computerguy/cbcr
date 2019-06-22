#!/bin/bash

docker build -t master:5000/ftpd:latest .
docker push master:5000/ftpd:latest
docker rmi stilliard/pure-ftpd:latest