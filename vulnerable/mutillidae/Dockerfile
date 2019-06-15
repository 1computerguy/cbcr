FROM citizenstig/nowasp:latest

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y iproute2 \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;