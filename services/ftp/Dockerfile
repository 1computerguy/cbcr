FROM stilliard/pure-ftpd:latest

RUN apt update && apt install iproute2 -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;

COPY chrony.conf /etc/chrony.conf

ADD docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh