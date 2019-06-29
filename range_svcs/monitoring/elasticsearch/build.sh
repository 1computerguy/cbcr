#!/bin/bash

docker build master:5000/elasticsearch:latest .
docker push master:5000/elasticsearch:latest
docker rmi docker.elastic.co/elasticsearch/elasticsearch-oss:6.1.0