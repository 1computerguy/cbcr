#!/bin/bash

docker build -t master:5000/kali:latest .
docker push master:5000/kali:latest
docker rmi kalilinux/kali-linux-docker