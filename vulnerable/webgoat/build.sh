#!/bin/bash

docker build -t master:5000/webgoat:latest .
docker push master:5000/webgoat:latest
docker rmi webgoat/webgoat-8.0:latest

docker build -t master:5000/webwolf:latest -f ./Dockerfile.webwolf
docker push master:5000/webwolf:latest
docker rmi webgoat/webwolf:latest