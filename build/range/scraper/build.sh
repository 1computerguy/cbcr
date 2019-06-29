#!/bin/bash

docker build -t master:5000/site-downloader:latest .
docker push master:5000/site-downloader:latest
docker rmi node:10-slim