#!/bin/bash

docker build -t master:5000/drupal:latest .
docker push master:5000/drupal:latest
docker rmi vulhub/drupal:8.5.0
