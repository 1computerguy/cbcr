FROM sameersbn/bind:latest

RUN apt update && apt install iproute2 -y \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;

ADD docker-entrypoint.sh /usr/local/share/docker-entrypoint.sh

RUN chmod +x /usr/local/share/docker-entrypoint.sh

ENTRYPOINT docker-entrypoint.sh

CMD ["/usr/sbin/named"]
