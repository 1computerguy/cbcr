FROM eeacms/postfix:latest

ADD docker-entrypoint.sh /docker-setup.sh

RUN chmod +x /docker-setup.sh

ENTRYPOINT ["/usr/bin/chaperone"]
