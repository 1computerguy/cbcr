#!/bin/bash

docker build -t master:5000/railsgoat:latest .
docker push master:5000/railsgoat
docker rmi owasp/railsgoat:latest