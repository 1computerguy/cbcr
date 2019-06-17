FROM nginx:alpine

COPY ssl.conf /etc/nginx/conf.d/

RUN apk add --no-cache iproute2

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT docker-entrypoint.sh