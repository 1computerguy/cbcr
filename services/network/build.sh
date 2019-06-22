#!/bin/bash

docker build -t master:5000/frr:latest .
docker push master:5000/frr:latest
docker rmi frrouting/frr:latest