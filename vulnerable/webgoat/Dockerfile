FROM webgoat/webgoat-8.0:latest

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    iproute2 sudo \
    echo "%wpscan  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ADD docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT docker-entrypoint.sh