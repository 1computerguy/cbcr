#!/bin/sh

sudo ip addr add $IP_ADDR/$LEN dev net1
sudo ip link set mtu 1450 dev net1
sudo ip r d default
sudo ip r a default via $GATEWAY

java -Djava.security.egd=file:/dev/./urandom -jar /home/webgoat/webgoat.jar --server.port=80 --server.address=0.0.0.0