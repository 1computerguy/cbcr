#!/bin/bash

docker build -t master:5000/filebeat:latest .
docker push master:5000/filebeat:latest
docker rmi store/elastic/filebeat:7.1.1