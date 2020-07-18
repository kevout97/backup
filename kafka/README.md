# Kafka 2.3.0

Creación de Imagen Kafka 2.3.0

# Prerequisitos

* Virtual CentOS7/Rhel
* Docker 1.13.X
* Imagen Docker dockeregistry.amovildigitalops.com/atomic-rhel7-java-8:latest
* Git

# Desarrollo

Clonamos el repositorio que contiene los archivos necesarios para la creación de la imagen.

```bash
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/kafka.git /opt/kafka
```

Construimos la imagen con el siguiente comando:

```bash
docker build -t dockeregistry.amovildigitalops.com/rhel7-atomic-kafka:2.3.0 /opt/kafka/docker
```

Para llevar a cabo el despliegue del contenedor hacemos uso del siguiente runit:

```bash
KAFKA_CONTAINER=kafka
KAFKA_VERSION=2.3.0

rm -rf /var/containers/$KAFKA_CONTAINER/opt/kafka_2.12-$KAFKA_VERSION/logs
mkdir -p /var/containers/$KAFKA_CONTAINER/opt/kafka_2.12-$KAFKA_VERSION/logs
chown 9092:0 /var/containers/$KAFKA_CONTAINER/opt/kafka_2.12-$KAFKA_VERSION/logs

docker rm -f $KAFKA_CONTAINER

docker run -d --name $KAFKA_CONTAINER \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /var/containers/$KAFKA_CONTAINER/opt/kafka_2.12-$KAFKA_VERSION/logs:/opt/kafka_2.12-$KAFKA_VERSION/logs:z \
    -p 9092:9092 \
    -e "KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181" \
    -e "KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://10.23.142.134:9092" \
    --hostname $KAFKA_CONTAINER \
    --add-host zookeeper:172.17.0.14 \
    dockeregistry.amovildigitalops.com/rhel7-atomic-kafka:2.0.3
```

Donde:
* **KAFKA_ZOOKEEPER_CONNECT**: Especifica la cadena de conexión de ZooKeeper en la forma *hostname:port* donde host y puerto son el host y el puerto de un servidor ZooKeeper. Para permitir la conexión a través de otros nodos de ZooKeeper cuando esa máquina ZooKeeper está inactiva, también puede especificar varios hosts en la forma *hostname1:port1, hostname2:port2, hostname3:port3* 


* **KAFKA_LISTENERS**: Los oyentes para publicar en ZooKeeper para que los clientes los usen, si son diferentes a la propiedad de configuración de los oyentes. En entornos IaaS, esto puede ser diferente de la interfaz a la que se une el intermediario. No es válido anunciar la meta-dirección 0.0.0.0.

**NOTA**: La imagen permite la configuración de cualquier propiedad contenida en el archivo [server.properties](docker/server.properties), a traves de variables de entorno (del comando runit), cuya estructura debe ser:
* Nombre de la variable en MAYUSCULAS
* El nombre de la variable debe iniciar con el prefijo KAFKA\_
* Los puntos del nombre de la propiedad deberán ser sustituidos por guiones bajo

E.g.

La propiedad **zookeeper.connection.timeout.ms** se convertiria en **KAFKA\_ZOOKEEPER\_CONNECTION\_TIMEOUT\_MS** 

