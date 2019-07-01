FROM citizenstig/nowasp

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN apt update && apt install iproute2 -y && \
    chmod +x /docker-entrypoint.sh && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;

ENTRYPOINT /docker-entrypoint.sh

CMD ["/run.sh"]