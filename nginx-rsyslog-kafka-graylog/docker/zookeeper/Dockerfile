FROM dockeregistry.amovildigitalops.com/atomic-rhel7-java-8

LABEL maintainer "Mauricio Melendez. Kevin Gomez. / AMX GA"

USER root

# Actualizacion de repositorios
RUN microdnf install shadow-utils -y && microdnf clean all && microdnf install wget -y && microdnf clean all

# Descarga de Zookeeper
WORKDIR /opt

RUN wget https://www-us.apache.org/dist/zookeeper/zookeeper-3.5.5/apache-zookeeper-3.5.5-bin.tar.gz && \
    tar -zxf apache-zookeeper-3.5.5-bin.tar.gz && \
    rm -f apache-zookeeper-3.5.5-bin.tar.gz && \
    mv apache-zookeeper-3.5.5-bin zookeeper-3.5.5 && \
    mkdir -p /opt/zookeeper-3.5.5/{data,logs,datalogs}

RUN groupadd -r zookeeper --gid=2181; \
    useradd -r -g zookeeper --uid=2181 zookeeper; \
    chown zookeeper:zookeeper /opt/zookeeper-3.5.5/{data,logs,conf,datalogs}

# Variable de entorno Zookeeper
ENV PATH="/opt/zookeeper-3.5.5/bin:$PATH" \
    JVMFLAGS="" \
    ZOO_CLIENT_PASSWORD="" \
    ZOO_CLIENT_USER="" \
    ZOO_HEAP_SIZE="1024" \
    ZOO_INIT_LIMIT="10" \
    ZOO_LOG_LEVEL="INFO" \
    ZOO_MAX_CLIENT_CNXNS="60" \
    ZOO_PORT_NUMBER="2181" \
    ZOO_RECONFIG_ENABLED="no" \
    ZOO_SERVERS="" \
    ZOO_SERVER_ID="1" \
    ZOO_SERVER_PASSWORDS="" \
    ZOO_SERVER_USERS="" \
    ZOO_SYNC_LIMIT="5" \
    ZOO_TICK_TIME="2000" \
    ZOO_DATA_DIR="/opt/zookeeper-3.5.5/data" \
    ZOO_CONF_DIR="/opt/zookeeper-3.5.5/conf" \
    ZOO_DATA_LOG_DIR="/opt/zookeeper-3.5.5/datalogs" \
    ZOO_LOG_DIR="/opt/zookeeper-3.5.5/logs" \
    ZOO_AUTOPURGE_PURGEINTERVAL="0" \
    ZOO_AUTOPURGE_SNAPRETAINCOUNT="3" 
    #ZOO_SERVERS="server.1=localhost:2888:3888"

# Instalación de gosu
ENV GOSU_VERSION=1.10 \
    GOSU_GPG_KEY=B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN cd /tmp && \
  curl -sSL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc -o gosu.asc && \
  curl -sSL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64 -o /usr/local/bin/gosu && \
  chmod +x /usr/local/bin/gosu && \
  rm gosu.asc


# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Voluemenes
# VOLUME [ "$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR", "$ZOO_LOG_DIR" ]

USER zookeeper
ENTRYPOINT ["/entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]

EXPOSE 2181 2888 3888