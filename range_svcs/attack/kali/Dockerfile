FROM kalilinux/kali-linux-docker

ENV DEBIAN_FRONTEND noninteractive
RUN set -x \
    && apt-get -yqq update \
    && apt-get -yqq dist-upgrade \
    && apt-get -yqq install iproute2 kali-linux-top10 \
    && apt-get clean

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh
