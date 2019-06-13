#!/bin/bash

docker build master:5000/ftpd:latest .
docker push master:5000/ftpd:latest
docker rmi stilliard/pure-ftpd:latest