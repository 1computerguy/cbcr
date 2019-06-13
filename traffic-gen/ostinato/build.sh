#!/bin/bash

docker build -t master:5000/ostinato:latest .
docker push master:5000/ostinato:latest
docker rmi ehlers/ostinato:latest