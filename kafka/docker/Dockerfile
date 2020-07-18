FROM dockeregistry.amovildigitalops.com/atomic-rhel7-java-8:latest

LABEL maintainer "Mauricio Melendez. Kevin Gomez."

USER root

RUN microdnf clean all && microdnf install wget -y

ENV KAFKA_VERSION 2.3.0

ENV KAFKA_DIR="/opt/kafka_2.12-$KAFKA_VERSION" 

ENV PATH="$KAFKA_DIR/bin:$PATH" 

RUN mkdir -p /opt/kafka-files && \
   wget https://www-us.apache.org/dist/kafka/$KAFKA_VERSION/kafka_2.12-$KAFKA_VERSION.tgz -P /opt/kafka-files && \
   tar -zxf /opt/kafka-files/kafka_2.12-$KAFKA_VERSION.tgz -C /opt && \
   rm -rf /opt/kafka-files/kafka_2.12-$KAFKA_VERSION.tgz && \
   mkdir -p $KAFKA_DIR/logs && \
   echo "kafka:x:9092:9092:Kafka service:/home/kafka:/sbin/nologin" >> /etc/passwd

COPY server.properties /opt/kafka-files

COPY docker-entrypoint.sh docker-health-check.sh /sbin/

RUN chmod +x /sbin/docker-entrypoint.sh && \
   chmod +x /sbin/docker-health-check.sh && \
   chown 9092:0 -R $KAFKA_DIR/ && \
   chown 9092:0 -R /opt/kafka-files

EXPOSE 9092

USER kafka

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
