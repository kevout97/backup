#!/bin/bash

#############################################################
#                                                           #
#  Runit para despliegue de Elasticsearch 7.6 en cluster    #
#                                                           #
#############################################################

# Permitir el trafico de los puertos
#   * 9200
#   * 9300
#   * 9400

# The vm.max_map_count kernel setting needs to be set to at least 262144 for production use
sysctl -w vm.max_map_count=262144

# Nombre del contenedor
ELASTIC_CONTAINER="jvpd3elas01-1.iris.io.service"

# Directorio para los volumenes
## NOTA: Estos directorios son para ELASTIC_PATH_DATA y ELASTIC_PATH_LOGS
mkdir -p /var/containers/$ELASTIC_CONTAINER/usr/share/elasticsearch/{data,logs}
chown 1000:0 -R /var/containers/$ELASTIC_CONTAINER

## Variables de entorno utilizadas en el docker run
ELASTIC_CLUSTER_NAME="jitsi-elasticsearch" # Nombre del cluster

ELASTIC_NODE_NAME="jvpd3elas01-1.iris.io"
ELASTIC_NODE_MASTER="true" # A node that has node.master set to true (default), which makes it eligible to be elected as the master node, which controls the cluster.
ELASTIC_NODE_DATA="true" # A node that has node.data set to true (default). Data nodes hold data and perform data related operations such as CRUD, search, and aggregations.
ELASTIC_NODE_INGEST="true" # A node that has node.ingest set to true (default). Ingest nodes are able to apply an ingest pipeline to a document in order to transform and enrich the document before indexing
ELASTIC_PATH_DATA="/usr/share/elasticsearch/data" # Directorio donde se almacenara la data
ELASTIC_PATH_LOGS="/usr/share/elasticsearch/logs" # Directorio donde se almacenaran los logs
ELASTIC_XPACK_SECURITY_ENABLED="false" # Habilita un tipo de nodo de Elastic que trabaja con Machin learning


ELASTIC_NETWORK_HOST="0.0.0.0" # The node will bind to this hostname or IP address and publish (advertise) this host to other nodes in the cluster. 
ELASTIC_NETWORK_PUBLISH_HOST="172.26.90.157" # (Aqui va la Ip del Servidor) The publish host is the single interface that the node advertises to other nodes in the cluster, so that those nodes can connect to it. 


# HTTP:
# Exposes the JSON-over-HTTP interface used by all clients other than the Java clients. See the HTTP module for more information.
ELASTIC_HTTP_HOST="0.0.0.0" # The host address to bind the HTTP service to. 
ELASTIC_HTTP_PORT="9200-9300" # A bind port range. Defaults to 9200-9300.
ELASTIC_HTTP_PUBLISH_PORT="9200" # The port that HTTP clients should use when communicating with this node. 
ELASTIC_HTTP_PUBLISH_HOST="172.26.90.157" # (Aqui va la Ip del servidor)	The host address to publish for HTTP clients to connect to.


# TCP Transport:
# Used for communication between nodes in the cluster, by the Java Transport client and by the Tribe node. See the Transport module for more information.
ELASTIC_TRANSPORT_TCP_PORT="9300-9400" # Port to bind for communication between nodes. A bind port range. Defaults to 9300-9400.
ELASTIC_TRANSPORT_HOST="0.0.0.0" # The host address to bind the transport service to. 
ELASTIC_TRANSPORT_PUBLISH_HOST="172.26.90.157" # (Aqui va la Ip del servidor) The host address to publish for nodes in the cluster to connect to.
ELASTIC_TRANSPORT_PUBLISH_PORT="9300" # The port that other nodes in the cluster should use when communicating with this node. 


ELASTIC_DISCOVERY_SEDD_HOSTS="172.26.90.157, 172.26.90.158, 172.26.90.159" # Unicast discovery requires a list of hosts to use that will act as gossip routers.
ELASTIC_CLUSTER_INITIAL_MASTER_NODES="jvpd3elas01-1.iris.io, jvpd3elas02-1.iris.io, jvpd3elas03-1.iris.io"


docker run  -itd --name $ELASTIC_CONTAINER \
    -h $ELASTIC_CONTAINER \
    --cap-add=IPC_LOCK \
    --ulimit nofile=65536:65536 \
    --ulimit memlock=-1:-1 \
    --memory-swappiness=0 \
    --restart always \
    -v /var/containers/$ELASTIC_CONTAINER/usr/share/elasticsearch/data:/usr/share/elasticsearch/data:z \
    -v /var/containers/$ELASTIC_CONTAINER/usr/share/elasticsearch/logs:/usr/share/elasticsearch/logs:z \
    -v /etc/localtime:/etc/localtime:ro \
    -e "cluster.name=$ELASTIC_CLUSTER_NAME" \
    -e "path.data=$ELASTIC_PATH_DATA" \
    -e "path.logs=$ELASTIC_PATH_LOGS" \
    -e "node.name=$ELASTIC_NODE_NAME" \
    -e "node.master=$ELASTIC_NODE_MASTER" \
    -e "node.data=$ELASTIC_NODE_DATA" \
    -e "node.ingest=$ELASTIC_NODE_INGEST" \
    -e "network.host=$ELASTIC_NETWORK_HOST" \
    -e "network.bind_host=0.0.0.0" \
    -e "network.publish_host=$ELASTIC_NETWORK_PUBLISH_HOST" \
    -e "http.host=$ELASTIC_HTTP_HOST" \
    -e "http.port=$ELASTIC_HTTP_PORT" \
    -e "http.publish_host=$ELASTIC_HTTP_PUBLISH_HOST" \
    -e "discovery.seed_hosts=$ELASTIC_DISCOVERY_SEDD_HOSTS" \
    -e "cluster.initial_master_nodes=$ELASTIC_CLUSTER_INITIAL_MASTER_NODES" \
    -e "xpack.security.enabled=$ELASTIC_XPACK_SECURITY_ENABLED" \
    -e "transport.tcp.port=$ELASTIC_TRANSPORT_TCP_PORT" \
    -e "transport.host=$ELASTIC_TRANSPORT_HOST" \
    -e "transport.publish_host=$ELASTIC_TRANSPORT_PUBLISH_HOST" \
    -e "http.publish_port=$ELASTIC_HTTP_PUBLISH_PORT" \
    -e "transport.publish_port=$ELASTIC_TRANSPORT_PUBLISH_PORT" \
    -e "bootstrap.memory_lock=true" \
    -e "node.ml=false" \
    -e "xpack.ml.enabled=false" \
    -e "ES_JAVA_OPTS=-Xms4G -Xmx4G" \
    -e TZ=America/Mexico_City \
    -p 9200:9200 \
    -p 9300:9300 \
    docker.elastic.co/elasticsearch/elasticsearch:7.6.1

curl -X GET "172.26.90.157:9200/_cluster/health?pretty"
curl -X GET "172.26.90.158:9200/_cluster/health?pretty"
curl -X GET "172.26.90.159:9200/_cluster/health?pretty"