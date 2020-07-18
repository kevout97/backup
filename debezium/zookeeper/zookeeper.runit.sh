#!/bin/bash
##################################################
#                                                #
#         Runit Zookeeper 3.7.5 HA               #
#                                                #
##################################################

ZOOKEEPER_CONTAINER="zookeeper-debezium"
ZOO_STANDALONE_ENABLED="false" # Deshabilita el modo standAlone
ZOO_JVMFLAGS="-Xmx1024m" # Configuraciones de Java
ZOO_MY_ID="1" # Id asociado para este nodo de Zookeeper (valores posibles 1 - 255)
ZOO_DATA_DIR="/var/lib/zookeeper" # Directtorio donde se almacenará la data
ZOO_DATA_LOG_DIR="/var/log/zookeeper" # Directorio donde se almacenarán los logs
ZOO_SERVERS="server.1:0.0.0.0:2888:3888;2181 server.2:zookeeper2-debezium:2888:3888;2181 server.3:zookeeper3-debezium:2888:3888;2181" # Lista de servidores que conforman el cluster de Zookeeper. 
               # Deben estar separadas por espacios
               # La sintaxis debe ser 
               #     server.id_server:<host>:<puerto por el que se conectaran con el master>:<puerto por el que decidiran quien es el master>;<puerto para conexion con el cliente>

# Los puertos por donde corre el servicio son:
#   Conexion con el Master:                 2888
#   Conexion con para elección del Master:  3888
#   Conexion con para los clientes:         2181

mkdir -p /var/containers/$ZOOKEEPER_CONTAINER/{var/lib/zookeeper,var/log/zookeeper,conf/}

cat <<-EOF > /var/containers/$ZOOKEEPER_CONTAINER/conf/zoo.cfg
dataDir=$ZOO_DATA_DIR
dataLogDir=$ZOO_DATA_LOG_DIR
tickTime=2000
initLimit=5
syncLimit=2
autopurge.snapRetainCount=3
autopurge.purgeInterval=0
maxClientCnxns=60
standaloneEnabled=false
admin.enableServer=true
clientPort=2181
EOF

for i in $ZOO_SERVERS; do
echo $i >> /var/containers/$ZOOKEEPER_CONTAINER/conf/zoo.cfg
done

echo $ZOO_MY_ID > /var/containers/$ZOOKEEPER_CONTAINER/var/lib/zookeeper/myid
chown 1000:0 -R /var/containers/$ZOOKEEPER_CONTAINER

docker run -itd --name $ZOOKEEPER_CONTAINER \
    -h $ZOOKEEPER_CONTAINER \
    --restart always \
    -p 2888:2888 \
    -p 3888:3888 \
    -p 2181:2181 \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/$ZOOKEEPER_CONTAINER/conf/zoo.cfg:/conf/zoo.cfg:z \
    -v /var/containers/$ZOOKEEPER_CONTAINER/var/lib/zookeeper:/var/lib/zookeeper:z \
    -v /var/containers/$ZOOKEEPER_CONTAINER/var/log/zookeeper:/var/log/zookeeper:z \
    -e "TZ=America/Mexico_City" \
    -e "ZOO_MY_ID=$ZOO_MY_ID" \
    --add-host zookeeper1-debezium:10.23.144.138 \
    --add-host zookeeper2-debezium:10.23.144.139 \
    --add-host zookeeper3-debezium:10.23.144.140 \
    zookeeper:3.5.7