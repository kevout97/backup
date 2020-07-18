FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio Meléndez && Kevin Gómez / GADT-AMX"

RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash - && \
    curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo && \
    microdnf install -y make python nodejs git && microdnf clean all

COPY entrypoint.sh /sbin

RUN chmod +x /sbin/entrypoint.sh && mkdir -p /konga-files

COPY .env /konga-files

EXPOSE 1337

ENTRYPOINT ["/sbin/entrypoint.sh"]