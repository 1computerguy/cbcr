FROM owasp/security-shepherd:latest

RUN apk add --no-cache iproute2

ADD docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT docker-entrypoint.sh