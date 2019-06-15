#!/bin/bash

docker build -t master:5000/nextcloud:latest .
docker push master:5000/nextcloud:latest
docker rmi linuxserver/nextcloud