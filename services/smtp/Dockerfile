FROM eeacms/postfix:latest

RUN yum install iproute2

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT docker-entrypoint.sh