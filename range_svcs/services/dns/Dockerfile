FROM resystit/bind9:latest

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN apk add --no-cache iproute2 && \
    chmod +x /docker-entrypoint.sh

ENTRYPOINT "/docker-entrypoint.sh"
