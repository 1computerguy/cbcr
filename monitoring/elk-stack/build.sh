#!/bin/bash

docker build master:5000/elk-stack:latest .
docker push master:5000/elk-stack:latest
docker rmi sebp/elk:latest