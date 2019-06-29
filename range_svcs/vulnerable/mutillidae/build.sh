#!/bin/bash

docker build -t master:5000/vuln-mutillidae:latest .
docker push master:5000/vuln-mutillidae:latest