#!/bin/bash

docker build -t master:5000/logstash:latest .
docker push master:5000/logstash:latest
docker rmi logstash:7.1.1