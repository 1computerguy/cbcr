FROM kylemanna/openvpn

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY vars /usr/local/bin/vars

RUN apk add --no-cache iproute2 &&\
    chmod +x /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh
