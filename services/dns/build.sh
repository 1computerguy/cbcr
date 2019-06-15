#!/bin/bash

docker build -t master:5000/bind:latest .
docker push master:5000/bind:latest
docker rmi sameersbn/bind