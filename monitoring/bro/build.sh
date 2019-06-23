#!/bin/bash

docker build -t master:5000/bro-ids:latest .
docker push master:5000/bro-ids:latest
docker rmi blacktop/bro:latest