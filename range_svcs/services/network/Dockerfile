FROM frrouting/frr:latest

COPY docker-start /docker-start

ENTRYPOINT [ "/sbin/tini", "--", "/docker-start" ]