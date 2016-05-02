FROM centos/tools
MAINTAINER jeder <jeder@redhat.com>

# Clone git repos for test tooling.
RUN git clone https://github.com/redhat-performance/docker-performance.git /root/docker-performance
RUN yum install -y https://dl.fedoraproject.org/pub/epel/6/x86_64/stress-1.0.4-4.el6.x86_64.rpm aspell && yum clean all
