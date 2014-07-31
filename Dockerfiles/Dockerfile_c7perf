FROM centos:centos7
MAINTAINER jeder <jeder@redhat.com>

# Install some useful utilities
RUN yum install -y bc blktrace btrfs-progs ethtool findutils gcc gdb git glibc-common glibc-utils gnuplot hwloc iotop iproute iputils less pciutils ltrace mailx man-db netsniff-ng net-tools numactl numactl-devel passwd perf procps-ng psmisc screen strace tar tcpdump vim-enhanced wget xauth which

# Clone git repos for test tooling.  # Could also be curl or whatever else...
RUN git clone https://github.com/jeremyeder/docker-performance.git /root/docker-performance
RUN yum install -y /root/docker-performance/utils/stress*
RUN ln -s /root/docker-performance/utils/nsinit /usr/bin

# Lay down some basic environment stuff
ENV container docker
ENV HOME /root
ENV USER root
WORKDIR /root
