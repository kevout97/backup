FROM dockeregistry.amovildigitalops.com/atomic-rhel7-java-8

USER root

ENV KEYCLOAK_VERSION="9.0.3" BASE_DIRECTORY="/opt/keycloak-9.0.3" \
    MYSQL_J_CONNECTOR_BASE_URL="https://dev.mysql.com/get/Downloads/Connector-J/" \
    MYSQL_J_CONNECTOR_FILE="mysql-connector-java-8.0.20.tar.gz" \
    LD_LIBRARY_PATH="/opt/rh/devtoolset-3/root/usr/lib64/"

RUN rm -rf /etc/yum.repos.d/* \
    && curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo \
    && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo \
    && microdnf clean all \
    && microdnf install tar iputils \
    && microdnf clean all

# Download and install Keycloak and mysql java connector
RUN mkdir -p /keycloak-files && \
    curl https://downloads.jboss.org/keycloak/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz -o /keycloak-files/keycloak-${KEYCLOAK_VERSION}.tar.gz \
    && curl -L ${MYSQL_J_CONNECTOR_BASE_URL}/${MYSQL_J_CONNECTOR_FILE} -o /keycloak-files/${MYSQL_J_CONNECTOR_FILE} \
    && ls /keycloak-files; tar xzf /keycloak-files/${MYSQL_J_CONNECTOR_FILE} -C /keycloak-files \
    && rm -rf /keycloak-files/${MYSQL_J_CONNECTOR_FILE} \
    && tar xzf /keycloak-files/keycloak-${KEYCLOAK_VERSION}.tar.gz -C /opt \
    && rm -f /keycloak-files/keycloak-${KEYCLOAK_VERSION}.tar.gz \
    && mkdir -p $BASE_DIRECTORY/modules/system/layers/keycloak/com/mysql/main \
    && mv -f /keycloak-files/${MYSQL_J_CONNECTOR_FILE%%.tar.gz}/${MYSQL_J_CONNECTOR_FILE%%.tar.gz}.jar $BASE_DIRECTORY/modules/system/layers/keycloak/com/mysql/main \
    && rm -rf /keycloak-files

RUN echo "keycloak:x:500:500:Keycloak Service:/home/keycloak:/sbin/nologin" >> /etc/passwd \
    && echo "keycloak:x:500:keycloak" >> /etc/group \
    && echo "PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8bW9kdWxlIHhtbG5zPSJ1cm46amJvc3M6bW9kdWxlOjEuMyIgbmFtZT0iY29tLm15c3FsIj4KIDxyZXNvdXJjZXM+CiAgPHJlc291cmNlLXJvb3QgcGF0aD0iX19teXNxbF9jb25uZWN0b3JfdmVyc2lvbl9fIiAvPgogPC9yZXNvdXJjZXM+CiA8ZGVwZW5kZW5jaWVzPgogIDxtb2R1bGUgbmFtZT0iamF2YXguYXBpIi8+CiAgPG1vZHVsZSBuYW1lPSJqYXZheC50cmFuc2FjdGlvbi5hcGkiLz4KIDwvZGVwZW5kZW5jaWVzPgo8L21vZHVsZT4KCg==" \
        | base64 -d -w0 \
        | sed -e "s/__mysql_connector_version__/${MYSQL_J_CONNECTOR_FILE%%.tar.gz}.jar/" \
        > $BASE_DIRECTORY/modules/system/layers/keycloak/com/mysql/main/module.xml \
    && chown keycloak:keycloak -R ${BASE_DIRECTORY} 

COPY config/*.xml $BASE_DIRECTORY/standalone/configuration/
COPY docker-entrypoint.sh docker-health-check.sh /sbin/

EXPOSE 8080 9990
WORKDIR $BASE_DIRECTORY
USER keycloak
HEALTHCHECK --interval=1m --timeout=15s CMD /sbin/docker-health-check.sh
ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]
