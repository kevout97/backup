FROM centos:7  
MAINTAINER Laurencio Galicia <laurencio.galicia@gmail.com> & INFRA-CTIN 

RUN yum -y  install epel-release.noarch && \
    yum -y localinstall http://linotp.org/rpm/el7/linotp/x86_64/Packages/LinOTP_repos-1.1-1.el7.x86_64.rpm  && \
    yum -y update  && \
    yum -y install LinOTP  LinOTP_apache  MySQL-python  httpd-tools  supervisor wget 

WORKDIR /tmp
COPY files.tar.gz /tmp/files.tar.gz
RUN  tar -xzf files.tar.gz && \
     /bin/bash config.sh
EXPOSE 443
#EXPOSE 80 443
ENTRYPOINT ["/bin/bash", "/tmp/entrypoint.sh"]
