#!/bin/bash

docker build -t master:5000/kibana .
docker push master:5000/kibana
docker rmi docker.elastic.co/kibana/kibana-oss:6.1.0