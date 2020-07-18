FROM dockeregistry.amovildigitalops.com/atomic-rhel7-java-8

LABEL maintainer="Mauricio Meléndez && Kevin Gómez / GADT-AMX"

USER root

RUN microdnf clean all && microdnf install shadow-utils wget -y && microdnf clean all && adduser -u 1001 nexus -m

RUN wget http://download.sonatype.com/nexus/3/nexus-3.19.1-01-unix.tar.gz -P /root/ && \
    wget https://nexus.san.gadt.amxdigital.net/repository/cloud/san/nexus-repository-composer-0.0.2.jar -P /root/

EXPOSE 8081

COPY docker-entrypoint.sh /sbin/

RUN chmod +x /sbin/docker-entrypoint.sh

COPY docker-health-check.sh /sbin/

RUN chmod +x /sbin/docker-health-check.sh

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]