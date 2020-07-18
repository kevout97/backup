FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL Description="Cassandra n-rdbm, AMX-CI Version" Vendor="AMX-SID-GI" Version="1.0"

LABEL maintainer="AMX-CI"

USER root

RUN bash -c "for repo in rhui-rhel-7-server-rhui-rpms rhui-rhel-server-rhui-rhscl-7-rpms cassandra; do curl https://repos.amxdigital.net/\${repo}.repo -o /etc/yum.repos.d/\${repo}.repo ; done"

RUN microdnf clean all && \
    microdnf install git make gcc jna autoconf yum && \
    mkdir -p /opt/jemalloc && \
    git clone https://github.com/jemalloc/jemalloc.git /opt/jemalloc && \
    cd /opt/jemalloc && \
    ./autogen.sh && \
    make && \
    make install && \
    cd / && \
    rm -rf /opt/jemalloc

RUN yum remove git make gcc autoconf jna -y && \
    microdnf clean all && \
    microdnf remove yum \
        python-urlgrabber \
        rpm-python \
        file-libs \
        rpm-build-libs \
        pygpgme \
        pyliblzma \
        python-iniparse \
        pyxattr \
        yum-metadata-parser \
        python-pycurl 

RUN microdnf update && \
    microdnf clean all && \
    microdnf install cassandra-3.11.5-1 elfutils jna python-pytz && \
    microdnf clean all

#ADD CA/* /etc/pki/ca-trust/source/anchors/

#RUN update-ca-trust enable && update-ca-trust extract

EXPOSE 7000 7001 7199 9042

STOPSIGNAL SIGQUIT

COPY docker-entrypoint.sh docker-health-check.sh /sbin/

COPY cassandra.yaml /etc/cassandra/conf

ENV CASSANDRA_FILE_PID "/var/run/cassandra.pid"

RUN echo "cassandra:x:999:998:Cassandra service:/home/cassandra:/sbin/nologin" >> /etc/passwd && \
touch /var/run/cassandra.pid && \
chown cassandra /var/run/cassandra.pid && \
chmod +x /sbin/docker-entrypoint.sh && \
chmod +x /sbin/docker-health-check.sh && \
mkdir -p /etc/ld.so.conf.d/ && \
echo "/usr/local/lib" > /etc/ld.so.conf.d/usrlocal.conf && \
chown -R cassandra /etc/cassandra/conf/ && \
chown -R cassandra /var/lib/cassandra

USER cassandra

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
