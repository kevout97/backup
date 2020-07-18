FROM dockeregistry.amovildigitalops.com/atomic-rhel7-java-8

LABEL maintainer="Mauricio Meléndez && Kevin Gómez / GADT-AMX"

USER root

COPY config/* /root/

RUN mkdir -p /deployments/config

ADD microcks-0.8.1.jar /microcks/microcks-0.8.1.jar

COPY entrypoint.sh /root/entrypoint.sh

RUN chmod +x /root/entrypoint.sh

EXPOSE 8080

ENTRYPOINT [ "/root/entrypoint.sh" ]