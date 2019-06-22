#!/bin/bash

docker build -t master:5000/softflowd:latest .
docker push master:5000/softflowd:latest
