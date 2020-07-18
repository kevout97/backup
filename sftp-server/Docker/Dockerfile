FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio Melendez & Kevin Gómez / AMX GA"

USER root

RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo && \
    microdnf install elfutils-libs openssh-server openssh-clients shadow-utils -y && microdnf clean all && \
    groupadd operaciones

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT [ "/entrypoint.sh" ]