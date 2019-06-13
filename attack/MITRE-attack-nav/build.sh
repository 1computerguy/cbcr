#!/bin/bash

docker build -t master:5000/mitre-attacknav:latest .
docker push master:5000/mitre-attacknav:latest
docker rmi davidjbianco/attacknav:latest