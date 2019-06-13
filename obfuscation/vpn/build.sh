#!/bin/bash

docker build master:5000/vpn:latest .
docker push master:5000/vpn:latest
docker rmi kylemanna/openvpn