#!/bin/bash

docker build -t master:5000/iperf:latest .
docker push master:5000/iperf:latest
