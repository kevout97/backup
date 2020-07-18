FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio Meléndez && Kevin Gómez / GADT-AMX"

USER root

RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo && \
    microdnf install wget shadow-utils unzip tar gzip libaio -y && microdnf clean all

RUN mkdir -p /mysql-files && wget https://nexus.san.gadt.amxdigital.net/repository/cloud/san/mysql8.zip -P /mysql-files

RUN microdnf install -y openssl \
    net-tools \
    procps \
    numactl-libs \
    yum && \
    microdnf clean all && \
    mkdir -p /mysql-files/mysql8 && \
    unzip /mysql-files/mysql8.zip -d /mysql-files/mysql8 && \
    rm -f /mysql-files/mysql8.zip && \
    tar -xzf /mysql-files/mysql8/mysql-commercial-8.0.18-1.1.el7.x86_64.repo.tar.gz -C /mysql-files && \
    rm -rf /mysql-files/mysql8/

RUN rpm --import /mysql-files/RPM-GPG-KEY-mysql && \
    cd /mysql-files/mysql-8.0/8.0.18/ && \
    yum install -y mysql-commercial-{server,client,common,libs,backup}-* && \
    rm -rf /mysql-files/mysql-8.0 && \
    microdnf remove yum -y && microdnf clean all

EXPOSE 3306

COPY docker-entrypoint.sh /sbin/

RUN chmod +x /sbin/docker-entrypoint.sh

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]