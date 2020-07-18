FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio Melendez & Kevin Gomez | AMX GADT"

COPY docker-entrypoint.sh docker-health-check.sh python-monitoring.py /sbin/

RUN curl https://repos.amxdigital.net/rhui-rhel-7-server-rhui-rpms.repo  -o /etc/yum.repos.d/rhui-rhel-7-server-rhui-rpms.repo && \
	curl https://repos.amxdigital.net/rhui-rhel-server-rhui-rhscl-7-rpms.repo -o /etc/yum.repos.d/rhui-rhel-server-rhui-rhscl-7-rpms.repo && \
    microdnf clean all && \
    microdnf install python python-inotify rsyslog && \
    chmod +x /sbin/docker-*

USER root

ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]