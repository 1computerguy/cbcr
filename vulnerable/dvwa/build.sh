#!/bin/bash

docker build -t master:5000/dvwa:latest .
docker push master:5000/dvwa:latest
docker rmi vulnerables/web-dvwa
