#!/bin/bash

docker build -t master:5000/webmail:latest .
docker push master:5000/webmail:latest
docker rmi analogic/poste.io:latest