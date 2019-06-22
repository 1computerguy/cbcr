FROM centos:latest
RUN yum install git autoconf gcc libpcap-devel make -y && \
	git clone https://github.com/djmdjm/softflowd.git && cd softflowd && \
	autoconf && autoheader && ./configure && make && make install && \
	yum install net-tools tcpdump -y && yum remove git autoconf gcc make -y