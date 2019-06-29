#!/bin/bash

docker build -t master:5000/smtp:latest .
docker push master:5000/smtp:latest
docker rmi eeacms/postfix:latest
