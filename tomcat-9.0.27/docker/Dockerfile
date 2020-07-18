FROM dockeregistry.amovildigitalops.com/atomic-rhel7-java-8

LABEL maintainer="Mauricio Meléndez && Kevin Gómez / GADT-AMX"

USER root

ENV TOMCAT_VERSION 9.0.27

ENV CATALINA_HOME /usr/local/apache-tomcat-$TOMCAT_VERSION

ENV JRE_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/jre

RUN echo "tomcat:x:9027:9027:Tomcat service:/home/tomcat:/sbin/nologin" >> /etc/passwd && \
    microdnf clean all && \
    microdnf install wget && \
    mkdir -p /opt/tomcat-files && \
    wget https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz -P /opt/tomcat-files/ && \
    mkdir -p /usr/local/ && \
    tar -zxf /opt/tomcat-files/apache-tomcat-$TOMCAT_VERSION.tar.gz -C /usr/local/ && \
    rm -f /opt/tomcat-files/tomcat-$TOMCAT_VERSION.tar.gz && \
    wget https://nexus.san.gadt.amxdigital.net/repository/cloud/san/tomcat-webapps.tar.gz -P /opt/tomcat-files && \
    wget https://nexus.san.gadt.amxdigital.net/repository/cloud/san/tomcat.conf.tar.gz -P /opt/tomcat-files && \
    chown 9027:0 -R /opt/tomcat-files && \
    chown 9027:0 -R /usr/local/apache-tomcat-$TOMCAT_VERSION

COPY docker-entrypoint.sh /sbin/docker-entrypoint.sh

COPY docker-health-check.sh /sbin/docker-health-check.sh

RUN chmod +x /sbin/docker-entrypoint.sh && chmod +x /sbin/docker-health-check.sh

EXPOSE 8080

USER tomcat

ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]