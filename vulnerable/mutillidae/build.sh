#!/bin/bash

docker build -t master:5000/mutillidae:latest .
docker push master:5000/mutillidae:latest
docker rmi citizenstig/nowasp:latest
