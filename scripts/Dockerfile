FROM gentoo/stage3-amd64

RUN mkdir -p /etc/portage/repos.conf/
ADD ethereum.conf /etc/portage/repos.conf/

ADD container_test.sh /root/
RUN chmod a+x /root/container_test.sh

WORKDIR /root
