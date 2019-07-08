FROM resystit/bind9:latest

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN apk add --no-cache iproute2 && \
    chmod +x /docker-entrypoint.sh && \
    mkdir -p /var/cache/bind && \
    chown -R named /var/cache/bind

ENTRYPOINT "/docker-entrypoint.sh"
