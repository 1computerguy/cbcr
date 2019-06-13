#!/bin/bash

docker build -t master:5000/rita:latest .
docker push master:5000/rita:latest
docker rmi quay.io/activecm/rita:latest