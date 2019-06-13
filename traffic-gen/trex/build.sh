#!/bin/bash

docker build -t master:5000/trex:latest .
docker push master:5000/trex:latest
docker rmi trexcisco/trex:latest