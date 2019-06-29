#!/bin/bash

docker build -t master:5000/nginx:latest .
docker push master:5000/nginx:latest
docker rmi nginx:alpine:latest
