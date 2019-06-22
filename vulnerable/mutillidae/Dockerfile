# Mutillidae Dockerfile
# Running on Ubuntu 16.04 Xampp v5.6.30 Stack
#
# Dockerfile: mutillidae-docker
# Author: Brennan Lee Turner (@BLTSEC)
# License: BSD 3-Clause
# https://github.com/BLTSEC/mutillidae-docker
#
# Pull base image
FROM ubuntu:16.04

# Working Directory
WORKDIR /root

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Install
RUN \
    apt-get update && \
    apt-get -y install wget && \
    apt-get install unzip iproute2 && \
    apt-get -y install supervisor && \
    wget -O xampp.run https://www.apachefriends.org/xampp-files/5.6.30/xampp-linux-x64-5.6.30-0-installer.run && \
    chmod +x ./xampp.run && \
    ./xampp.run --mode unattended && \
    wget -O mutillidae.zip https://sourceforge.net/projects/mutillidae/files/latest/download && \
    unzip mutillidae.zip && \
    cp -r mutillidae /opt/lampp/htdocs/ && \
    sed -i 's/Deny/Allow/g' /opt/lampp/htdocs/mutillidae/.htaccess && \
    sed -i -E 's/,Allow/,Deny/' /opt/lampp/htdocs/mutillidae/.htaccess && \
    echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:xampp]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/bin/bash -c '/opt/lampp/xampp start'" >> /etc/supervisor/conf.d/supervisord.conf && \
    chmod +x /docker-entrypoint.sh

EXPOSE 80 443 3306

ENTRYPOINT /docker-entrypoint.sh