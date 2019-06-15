FROM analogic/poste.io:latest

RUN apt update && apt install iproute2 \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;