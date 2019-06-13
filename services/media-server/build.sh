#!/bin/bash

docker build -t master:5000/media:latest .
docker push master:5000/media:latest
docker rmi silverwind/droppy:latest