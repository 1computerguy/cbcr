#!/bin/bash

docker build -t master:5000/ntpd:latest .
docker push master:5000/ntpd:latest
docker rmi publicarray/chrony:latest