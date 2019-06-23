#!/bin/bash

docker build master:5000/openvpn:latest .
docker push master:5000/openvpn:latest
docker rmi kylemanna/openvpn:latest