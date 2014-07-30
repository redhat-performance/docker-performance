docker-performance
==================

Repository to accompany https://slides.com/jeremyeder/docker-performance-analysis

# git clone https://github.com/jeremyeder/docker-performance.git
# docker build -t c7perf --rm=true - < /root/docker-performance/Dockerfiles/Dockerfile_c7perf
# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
c7perf              latest              f275641e482b        38 seconds ago      663.7 MB
centos              centos7             1a7dc42f78ba        2 weeks ago         236.4 MB

# mkdir /results
# chcon -Rt svirt_sandbox_file_t /results
# docker run -it -v /results:/results c7perf bash
# /root/docker-performance/bench/sysbench/run-sysbench.sh cpu test1
# cat /results/*histogram

...
# cat /etc/hostname
2bf50285b249
# chcon --reference /var/lib/docker/devicemapper/mnt/2bf50285b249d1513c5481a992b12495fc8e8e0d3fdf2b2345b760c5fd675db1 /results
