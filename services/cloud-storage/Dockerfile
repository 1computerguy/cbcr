FROM nextcloud:latest

RUN apk add --no-cache iproute2

ADD docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT /entrypoint.sh

CMD ["apache2-foreground"]