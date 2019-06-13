#!/bin/bash

docker build -t master:5000/ntp:latest .
docker push master:5000/ntp:latest