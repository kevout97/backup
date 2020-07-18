FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio Melendez & Kevin Gomez | AMX GADT"

COPY docker-* /sbin/

USER root

RUN curl https://repos.amxdigital.net/rhui-rhel-7-server-rhui-rpms.repo  -o /etc/yum.repos.d/rhui-rhel-7-server-rhui-rpms.repo && \
    curl https://repos.amxdigital.net/rhui-rhel-server-rhui-rhscl-7-rpms.repo -o /etc/yum.repos.d/rhui-rhel-server-rhui-rhscl-7-rpms.repo && \
    microdnf install yum && \
    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y && \
    yum clean all && \
    yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/sendmail-8.14.7-5.el7.x86_64.rpm \
        http://mirror.centos.org/centos/7/os/x86_64/Packages/sendmail-milter-8.14.7-5.el7.x86_64.rpm \
        http://mirror.centos.org/centos/7/os/x86_64/Packages/sendmail-devel-8.14.7-5.el7.x86_64.rpm \
        opendkim mailx openssl openssl-devel && \
    rm -f /etc/opendkim.conf && \
    chmod +x /sbin/docker-entrypoint.sh && \
    chmod +x /sbin/docker-health-check.sh

COPY opendkim.conf /etc/

ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]

HEALTHCHECK --interval=10s --retries=3 CMD [ "/sbin/docker-health-check.sh" ]