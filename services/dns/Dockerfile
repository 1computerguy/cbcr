FROM sameersbn/bind:latest

RUN apt update && apt install iproute2 -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV BIND_USER=bind \
    BIND_VERSION=9.11.3 \
    WEBMIN_VERSION=1.9 \
    DATA_DIR=/data

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT "docker-entrypoint.sh"

CMD ["/usr/sbin/named"]
