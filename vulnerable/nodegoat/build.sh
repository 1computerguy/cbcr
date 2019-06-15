#!/bin/bash

docker build -t master:5000/nodegoat:latest .
docker push master:5000/nodegoat:latest
docker rmi 1njected/nodegoat:latest

docker build -t master:5000/mongodb:latest -f ./Dockerfile.mongo
docker push master:5000/mongodb:latest
docker rmi mongo:latest