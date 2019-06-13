#!/bin/bash

docker build -t master:5000/juice-shop:latest .
docker push master:5000/juice-shop:latest
docker rmi bkimminich/juice-shop
