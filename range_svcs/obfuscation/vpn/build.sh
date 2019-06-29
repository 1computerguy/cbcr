#!/bin/bash

docker build -t master:5000/openvpn:latest .
docker push master:5000/openvpn:latest
docker rmi kylemanna/openvpn:latest