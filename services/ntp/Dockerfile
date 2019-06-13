FROM alpine:3.8 as build
MAINTAINER David Chidell (dchidell@cisco.com)

FROM build as webproc
ENV WEBPROC_VERSION 0.2.2
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/$WEBPROC_VERSION/webproc_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build as chronyd
RUN apk --no-cache add chrony iproute2
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
COPY chrony.conf /etc/chrony/chrony.conf
ENTRYPOINT ["webproc","--on-exit","restart","--config","/etc/chrony/chrony.conf","--","chronyd","-d"]