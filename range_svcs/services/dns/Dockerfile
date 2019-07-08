FROM resystit/bind9:latest

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN apk add --no-cache iproute2 && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT "docker-entrypoint.sh"
