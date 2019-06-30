FROM frrouting/frr:latest

COPY docker-start /docker-start

RUN chmod +x /docker-start

ENTRYPOINT [ "/sbin/tini", "--", "/docker-start" ]