FROM centos:centos7  
MAINTAINER Laurencio Galicia <laurencio.galicia@gmail.com> & INFRA-CTIN 

WORKDIR /etc/yum.repos.d 
RUN yum update -y \
    && rpm -Uvh https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/spacewalk-2.8/epel-7-x86_64/00736372-spacewalk-repo/spacewalk-repo-2.8-11.el7.centos.noarch.rpm \ 
    && rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && curl -O https://copr.fedorainfracloud.org/coprs/g/spacewalkproject/java-packages/repo/epel-7/group_spacewalkproject-java-packages-epel-7.repo \
    && yum -y install spacewalk-postgresql supervisor 

WORKDIR /tmp
COPY files.tar.gz /tmp/files.tar.gz
WORKDIR /tmp
RUN  tar -xzf files.tar.gz && \
     /bin/bash config.sh
EXPOSE 80 443 5222 68 69
ENTRYPOINT ["/bin/bash", "/tmp/entrypoint.sh"]
