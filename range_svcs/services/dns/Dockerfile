FROM sameersbn/bind:latest

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN apt update && apt install iproute2 -y && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;

ENTRYPOINT "docker-entrypoint.sh"

CMD ["/usr/sbin/named"]
