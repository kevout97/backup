# Debezium 1.1

Despliegue de Debezium 1.1

## Prerrequisitos

+ RHEL 7
+ Docker 1.13 o superior.
+ Imagen docker-source-registry.amxdigital.net/atomic_mysql5729_all:5.7.29

## Despliegue de Debezium con Mysql 5.7.29

### Zookeeper

Se prepara el clúster de Zookeeper para que trabaje en HA.

```sh
#!/bin/bash
##################################################
#                                                #
#         Runit Zookeeper 3.7.5 HA               #
#                                                #
##################################################

ZOOKEEPER_CONTAINER="zookeeper-debezium"
ZOO_STANDALONE_ENABLED="false"
ZOO_JVMFLAGS="-Xmx1024m"
ZOO_MY_ID="1"
ZOO_DATA_DIR="/var/lib/zookeeper"
ZOO_DATA_LOG_DIR="/var/log/zookeeper"
ZOO_SERVERS="server.1:0.0.0.0:2888:3888;2181 server.2:zookeeper2-debezium:2888:3888;2181 server.3:zookeeper3-debezium:2888:3888;2181"

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
```

Donde:

+ ZOO_STANDALONE_ENABLED="false" => Deshabilita el modo standAlone
+ ZOO_JVMFLAGS="-Xmx1024m" => Configuraciones de Java
+ ZOO_MY_ID="1" => Id asociado para este nodo de Zookeeper (valores posibles 1 - 255)
+ ZOO_DATA_DIR="/var/lib/zookeeper" => Directtorio donde se almacenará la data
+ ZOO_DATA_LOG_DIR="/var/log/zookeeper" => Directorio donde se almacenarán los logs
+ ZOO_SERVERS="server.1:0.0.0.0:2888:3888;2181 server.2:zookeeper2-debezium:2888:3888;2181 server.3:zookeeper3-debezium:2888:3888;2181" => Lista de servidores que conforman el clúster de Zookeeper. 
  + Deben estar separadas por espacios
  + La sintaxis debe ser:
  + server.id_server:\<host>:\<puerto por el que se conectaran con el master>:\<puerto por el que decidiran quien es el master>;\<puerto para conexion con el cliente>

+ Los puertos por donde corre el servicio son:
  + Conexion con el Master:                 2888
  + Conexion con para elección del Master:  3888
  + Conexion con para los clientes:         2181

### Kafka con compatibilidad con Debezium

Levantamiento y conexión de Kafka con Zookeeper

```sh
#!/bin/bash
##################################################
#                                                #
#               Runit Kafka 1.1                  #
#                                                #
##################################################

KAFKA_CONTAINER="kafka-debezium"
KAFKA_BROKER_ID="1"
KAFKA_HEAP_OPTS="-Xmx512m -Xms512m"
KAFKA_ZOOKEEPER_CONNECT="10.23.144.138:2181"
KAFKA_ADVERTISED_HOST_NAME="10.23.144.138"

mkdir -p /var/containers/$KAFKA_CONTAINER/{kafka/data,kafka/logs}
chown 1001:0 -R /var/containers/$KAFKA_CONTAINER/

docker run -itd --name $KAFKA_CONTAINER \
    --restart always \
    -h $KAFKA_CONTAINER \
    -p 9092:9092 \
    -v /var/containers/$KAFKA_CONTAINER/kafka/data:/kafka/data:z \
    -v /var/containers/$KAFKA_CONTAINER/kafka/logs:/kafka/logs:z \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "BROKER_ID=$KAFKA_BROKER_ID" \
    -e "HOST_NAME=$KAFKA_CONTAINER" \
    -e "ADVERTISED_HOST_NAME=$KAFKA_ADVERTISED_HOST_NAME" \
    -e "ZOOKEEPER_CONNECT=$KAFKA_ZOOKEEPER_CONNECT" \
    -e "HEAP_OPTS=$KAFKA_HEAP_OPTS" \
    debezium/kafka:1.1
```

Donde:

+ KAFKA_CONTAINER="kafka-debezium" => Nombre del contenedor
+ KAFKA_BROKER_ID="1" => Se recomienda esta variable de entorno. Establezca esto en el número único y persistente para el clúster. Esto debe establecerse para cada clúster en un clúster de Kafka, y debe establecerse para el modo standalone. El valor predeterminado es '1', y establecer esto actualizará la configuración de Kafka.
+ KAFKA_HEAP_OPTS="-Xmx512m -Xms512m" => Opciones JVM para el broker kafka.
+ KAFKA_ZOOKEEPER_CONNECT="10.23.144.138:2181" => Servidor y puerto Zookeeper a conectar.
+ KAFKA_ADVERTISED_HOST_NAME="10.23.144.138" => Ip del host donde se monte el broker Kafka.

### Debezium Connect

Levantamiento del connect de Debezium.

```sh
#!/bin/bash
##################################################
#                                                #
#         Runit Debezium Connect 1.1             #
#                                                #
##################################################

DEBEZIUM_CONNECT_CONTAINER="connect-debezium"
DEBEZIUM_CONNECT_GROUP_ID="1"
DEBEZIUM_CONNECT_STATUS_STORAGE_TOPIC="my_connect_statues"
DEBEZIUM_CONNECT_CONFIG_STORAGE_TOPIC="my_connect_config"
DEBEZIUM_CONNECT_OFFSET_STORAGE_TOPIC="my_connect_offsets"
DEBEZIUM_CONNECT_BOOTSTRAP_SERVERS="10.23.144.138:9092"
DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME="10.23.144.138"
DEBEZIUM_CONNECT_ADVERTISED_PORT="8083"
DEBEZIUM_CONNECT_HEAP_OPTS="-Xmx512m -Xms512m"
DEBEZIUM_CONNECT_NAME="mysql-connector"
DEBEZIUM_CONNECT_DB_HOST="10.23.144.138"
DEBEZIUM_CONNECT_DB_PORT="3306"
DEBEZIUM_CONNECT_DB_USER="root"
DEBEZIUM_CONNECT_DB_PASS="abcd1234"
DEBEZIUM_CONNECT_DB_NAME="MyGuests"
DEBEZIUM_CONNECT_DB_ID="223344"
DEBEZIUM_CONNECT_SERVER_NAME="mysql-first"
DEBEZIUM_CONNECT_KAFKA_SERVERS="10.23.144.138:9092"
DEBEZIUM_CONNECT_KAFKA_TOPIC="schema-changes.MyGuests"

docker run -itd --name $DEBEZIUM_CONNECT_CONTAINER \
    --restart always \
    -p $DEBEZIUM_CONNECT_ADVERTISED_PORT:8083 \
    -h $DEBEZIUM_CONNECT_CONTAINER \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "GROUP_ID=$DEBEZIUM_CONNECT_GROUP_ID" \
    -e "CONFIG_STORAGE_TOPIC=$DEBEZIUM_CONNECT_CONFIG_STORAGE_TOPIC" \
    -e "STATUS_STORAGE_TOPIC=$DEBEZIUM_CONNECT_STATUS_STORAGE_TOPIC" \
    -e "OFFSET_STORAGE_TOPIC=$DEBEZIUM_CONNECT_OFFSET_STORAGE_TOPIC" \
    -e "BOOTSTRAP_SERVERS=$DEBEZIUM_CONNECT_BOOTSTRAP_SERVERS" \
    -e "ADVERTISED_HOST_NAME=$DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME" \
    -e "ADVERTISED_PORT=$DEBEZIUM_CONNECT_ADVERTISED_PORT" \
    -e "HOST_NAME=$DEBEZIUM_CONNECT_CONTAINER" \
    -e "HEAP_OPTS=$DEBEZIUM_CONNECT_HEAP_OPTS" \
    debezium/connect:1.1
```

Donde:

+ DEBEZIUM_CONNECT_CONTAINER="connect-debezium" => Nombre del contenedor.
+ DEBEZIUM_CONNECT_GROUP_ID="1" => Esta variable es necesaria cuando se ejecuta el servicio Kafka Connect. ID único que identifica de forma exclusiva el clúster de Kafka Connect.
+ DEBEZIUM_CONNECT_STATUS_STORAGE_TOPIC="my_connect_statues" => Nombre para topic de kafka sobre status.
+ DEBEZIUM_CONNECT_CONFIG_STORAGE_TOPIC="my_connect_config" => Nombre para topic de kafka sobre configuración de conectores.
+ DEBEZIUM_CONNECT_OFFSET_STORAGE_TOPIC="my_connect_offsets" => Nombre para topic de kafka sobre offsets del conector.
+ DEBEZIUM_CONNECT_BOOTSTRAP_SERVERS="10.23.144.138:9092" => Host Kafka, pueden ser varios separados por comas. host1:port1,host2:port2,...
+ DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME="10.23.144.138" => Hostname o ip del host donde se despliega el conector.
+ DEBEZIUM_CONNECT_ADVERTISED_PORT="8083" => Puerto por el que se utiliza el conector.
+ DEBEZIUM_CONNECT_HEAP_OPTS="-Xmx512m -Xms512m" => Opciones JVM para el conector.

### Mysql 5.7.29

```sh
#!/bin/bash

CONTAINER=mysql


mkdir -p /var/containers/${CONTAINER}/
chown 1017:1017 -R /var/containers/${CONTAINER}/
hostname=$(hostname)

# Destroy container
docker rm -f ${CONTAINER}
#rm -rf /var/containers/${CONTAINER}/

# Run container
docker run -itd --name=${CONTAINER} \
    --hostname=${CONTAINER}.service \
    --ulimit nofile=40240:40240 \
    --ulimit nproc=35000:40960 \
    --health-cmd='/bin/true' \
    --health-interval=120s \
    -p 3306:3306 \
    -e 'DEBUG=1' \
    -e 'LANG=en_US.UTF-8' \
    -e 'MYSQL_ROOT_PASSWORD=abcd1234' \
    --restart unless-stopped \
    -v /var/backups/mysqldailybackup/:/var/backups/mysqldailybackup/:z \
    -v /var/containers/${CONTAINER}/var/log/mysql/:/var/log/mysql/:Z \
    -v /var/containers/${CONTAINER}/var/log/mysql/Binlogs:/var/log/mysql/Binlogs:Z \
    -v /var/containers/${CONTAINER}/var/log/mysql/Bitacora:/var/log/mysql/Bitacora:Z \
    -v /var/containers/${CONTAINER}/var/log/mysql/Audit:/var/log/mysql/Audit:Z \
    -v /var/containers/${CONTAINER}/UD01/mysql/data/:/UD01/mysql/data/:Z \
    -v /var/containers/${CONTAINER}/etc/mysql/:/etc/mysql/:Z \
    -v /var/containers/${CONTAINER}/var/backups/ejecucionesscript/:/var/backups/ejecucionesscript/:Z \
    -v /var/containers/${CONTAINER}/var/tmp/mysql/:/var/tmp/mysql/:Z \
    -v /etc/localtime:/etc/localtime:ro \
    -e "mysql_var_back_log =80" \
    -e "mysql_var_binlog_format=MIXED" \
    -e "mysql_var_binlog_row_event_max_size =8K" \
    -e "mysql_var_character_set_client_handshake = FALSE" \
    -e "mysql_var_character_set_server = utf8mb4" \
    -e "mysql_var_collation_server = utf8mb4_unicode_ci" \
    -e "mysql_var_datadir=/UD01/mysql/data" \
    -e "mysql_var_default_storage_engine=innodb" \
    -e "mysql_var_expire_logs_days =4" \
    -e "mysql_var_flush_time =0" \
    -e "mysql_var_general_log =1" \
    -e "mysql_var_general_log_file =/var/log/mysql/general.log" \
    -e "mysql_var_innodb_autoextend_increment =64" \
    -e "mysql_var_innodb_autoinc_lock_mode =2" \
    -e "mysql_var_innodb_buffer_pool_instances = 16" \
    -e "mysql_var_innodb_buffer_pool_size=1G" \
    -e "mysql_var_innodb_checksum_algorithm =crc32" \
    -e "mysql_var_innodb_concurrency_tickets =5000" \
    -e "mysql_var_innodb_fast_shutdown =0" \
    -e "mysql_var_innodb_file_per_table =1" \
    -e "mysql_var_innodb_flush_log_at_trx_commit =0" \
    -e "mysql_var_innodb_log_buffer_size =8M" \
    -e "mysql_var_innodb_log_file_size =2G" \
    -e "mysql_var_innodb_old_blocks_time =1000" \
    -e "mysql_var_innodb_open_files =300" \
    -e "mysql_var_innodb_page_cleaners = 8" \
    -e "mysql_var_innodb_read_io_threads =16" \
    -e "mysql_var_innodb_stats_persistent =1" \
    -e "mysql_var_innodb_stats_persistent_sample_pages =100" \
    -e "mysql_var_innodb_temp_data_file_path =ibtmp1:12M:autoextend:max:15G" \
    -e "mysql_var_innodb_write_io_threads =4" \
    -e "mysql_var_join_buffer_size =256K" \
    -e "mysql_var_log_bin_trust_function_creators" \
    -e "mysql_var_log_queries_not_using_indexes=0" \
    -e "mysql_var_log_timestamps='SYSTEM'" \
    -e "mysql_var_long_query_time=5" \
    -e "mysql_var_lower_case_table_names=1" \
    -e "mysql_var_max_allowed_packet=1G" \
    -e "mysql_var_max_connect_errors=100" \
    -e "mysql_var_max_connections=500" \
    -e "mysql_var_port = 3306" \
    -e "mysql_var_query_cache_size = 0" \
    -e "mysql_var_query_cache_type = 0" \
    -e "mysql_var_slow_query_log =1" \
    -e "mysql_var_slow_query_log_file = /var/log/mysql/slow.log" \
    -e "mysql_var_sort_buffer_size =128K" \
    -e "mysql_var_sync_binlog =1" \
    -e "mysql_var_table_definition_cache =1400" \
    -e "mysql_var_table_open_cache =2064" \
    -e "mysql_var_table_open_cache_instances =16" \
    -e "mysql_var_thread_cache_size =9" \
    -e "mysql_var_tmp_table_size =8M" \
    -e "mysql_var_user=mysql" \
    -e "TZ=UTC" \
    docker-source-registry.amxdigital.net/atomic_mysql5729_all:5.7.29
```

> Importante la variable *TZ=UTC* para compatibilidad del conector con la zona horaria.

Añadir las siguientes directivas en el archivo my.cnf en el bloque [mysqld]

```sh
log_bin           = /var/log/mysql/Binlogs/mysql-bin
binlog_format     = row
binlog_row_image  = full
expire_logs_days  = 5
gtid_mode                 = on
enforce_gtid_consistency  = on
binlog_rows_query_log_events = on
```

Donde:

+ log_bin           = /var/log/mysql/Binlogs/mysql-bin => Archivos de binlog
+ binlog_format     = row => Formato de binlog.
+ binlog_row_image  = full => Imafen para binlog.
+ expire_logs_days  = 5 => Días en los que se hace un borrado automático de binlog.
+ gtid_mode         = on => Enciende GTID mode. (Opcional)
+ enforce_gtid_consistency  = on => Instruye al servidor para que imponga la consistencia de GTID al permitir la ejecución de sólo aquellas declaraciones que se pueden registrar de una manera transaccionalmente segura, y que se requiere cuando se usan GTID. (Opcional pero necesario si se enciende el modo GTID).
+ binlog_rows_query_log_events = on => Habilita el soporte para incluir la declaración SQL original en la entrada binlog. (Opcional)

#### Permitir conexiones remotas en BD

Conectar a la base de datos con el usuario root.

```sh
docker exec -it mysql /usr/local/mysql/bin/mysql -uroot -p
```

En la consola mysql:

> Este ejemplo se hace para el usuario root. Aplica igual para X usuario.

```sh
update mysql.user set mysql.user.Host="%" where mysql.user.User="root";
flush privileges;
```

Agregar el host que se conectará a la db en el archivo de configuración my.cnf con la directiva *bind-address=0.0.0.0* en el bloque [mysqld] sustituyendo 0.0.0.0 por la ip deseada o dejando 0.0.0.0 para aceptar cualquier host.

Reiniciar contenedor mysql

```sh
docker restart mysql
```

Si se utiliza un usuario dedicado para Debezium, debe tener los siguientes permisos:

+ SELECT
+ RELOAD
+ SHOW DATABASES
+ REPLICATION SLAVE
+ REPLICATION CLIENT

Ejemplo para el usuario debezium con password dbz.

```sh
docker exec -it mysql /usr/local/mysql/bin/mysql -uroot -p
```

En la consola mysql:

```sh
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium' IDENTIFIED BY 'dbz';
```

### Ejemplo para verificar funcionalidad del conector

```sh
DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME="10.23.144.138"
DEBEZIUM_CONNECT_ADVERTISED_PORT="8083"
DEBEZIUM_CONNECT_NAME="mysql-connector"
DEBEZIUM_CONNECT_DB_HOST="10.23.144.138"
DEBEZIUM_CONNECT_DB_PORT="3306"
DEBEZIUM_CONNECT_DB_USER="root"
DEBEZIUM_CONNECT_DB_PASS="abcd1234"
DEBEZIUM_CONNECT_DB_NAME="MyGuests"
DEBEZIUM_CONNECT_DB_ID="223344"
DEBEZIUM_CONNECT_SERVER_NAME="mysql-first"
DEBEZIUM_CONNECT_KAFKA_SERVERS="10.23.144.138:9092"
DEBEZIUM_CONNECT_KAFKA_TOPIC="schema-changes.MyGuests"

cat<<-EOF > $DEBEZIUM_CONNECT_NAME.json
{"name":
    "$DEBEZIUM_CONNECT_NAME",
    "config":{
        "connector.class":"io.debezium.connector.mysql.MySqlConnector",
        "database.hostname":"$DEBEZIUM_CONNECT_DB_HOST",
        "database.port":"$DEBEZIUM_CONNECT_DB_PORT",
        "database.user":"$DEBEZIUM_CONNECT_DB_USER",
        "database.password":"$DEBEZIUM_CONNECT_DB_PASS",
        "database.server.id":"$DEBEZIUM_CONNECT_DB_ID",
        "database.server.name":"$DEBEZIUM_CONNECT_SERVER_NAME",
        "database.whitelist":"$DEBEZIUM_CONNECT_DB_NAME",
        "database.history.kafka.bootstrap.servers":"$DEBEZIUM_CONNECT_KAFKA_SERVERS",
        "database.history.kafka.topic":"$DEBEZIUM_CONNECT_KAFKA_TOPIC"
    }
}
EOF

echo "[AMX $(date)] Set connector"
curl -i -X POST -H "Accept:application/json" \
    -H "Content-Type:application/json" $DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME:$DEBEZIUM_CONNECT_ADVERTISED_PORT/connectors/ \
    -d @$DEBEZIUM_CONNECT_NAME.json

rm -f $DEBEZIUM_CONNECT_NAME.json

curl -H "Accept:application/json" $DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME:$DEBEZIUM_CONNECT_ADVERTISED_PORT/connectors/
```

Donde:

+ DEBEZIUM_CONNECT_NAME="mysql-connector" => Nombre para el json de prueba.
+ DEBEZIUM_CONNECT_DB_HOST="10.23.144.138" => Host de la DB.
+ DEBEZIUM_CONNECT_DB_PORT="3306" => Puerto de la DB.
+ DEBEZIUM_CONNECT_DB_USER="root" => Usuario de la DB.
+ DEBEZIUM_CONNECT_DB_PASS="abcd1234" => Password del usuario que se conecta a la DB.
+ DEBEZIUM_CONNECT_DB_NAME="MyGuests" => Nombre de la DB sobre la que trabajará el connector en el ejempplo.
+ DEBEZIUM_CONNECT_DB_ID="223344" => Alias para conexión.
+ DEBEZIUM_CONNECT_SERVER_NAME="mysql-first" => ID unico para conexión.
+ DEBEZIUM_CONNECT_KAFKA_SERVERS="10.23.144.138:9092" => Host y puerto del broker kafka.
+ DEBEZIUM_CONNECT_KAFKA_TOPIC="schema-changes.MyGuests" => Topic asignado para el ejemplo.
+ DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME="10.23.144.138" => Hostname o ip del host donde se despliega el conector.
+ DEBEZIUM_CONNECT_ADVERTISED_PORT="8083" => Puerto por el que se utiliza el conector.


## Configuraciones extras del Conector.

A continuación se muestran las configuraciones extras que pueden ser incluidas en el conector.

##### connector.class

Clase java utilizada para la conexión con el gestor de la base de datos, para una conexión con mysql el valor debe ser **io.debezium​.connector.mysql.MySqlConnector**

##### tasks.max

Número maximo de tareas que el conector puede generar dentro del gestor de base de datos, el valor por defecto es 1.

##### database.hostname

Ip o hostname donde esta situada la base de datos a monitorear.

##### database.port

Puerto para la conexión con la base de datos.

##### database.user

Usuario para la conexión con la base de datos.

##### database.password

Password del usuario utilizado para la conexión con la base de datos.

##### database.server.name

Crea un espacio de nombre en los topics de Kafka el cual particulariza a este conector, debe ser único para cada conector.

##### database.server.id

Id que asocia debezium a dicha base de datos, es util cuando se hace un monitoreo de la misma base desde otro servidor, su funcion se refleja cuando se tiene un cluster, evita monitoreos dobles.

##### database.history.kafka.topic

Nombre del topic en kafka

##### database.history​.kafka.bootstrap.servers

Lista de servidores de kafka

##### database.whitelist

Nombre de las bases de datos que seran monitoreadas, por defecto se monitorean todas, deben estar separadas por una coma. Acepta expresiones regulares.

##### database.blacklist

Nombre las bases de datos que no deben ser monitoreadas, el resto de bases de datos que no esten en esta lista seran monitoreadas. Acepta expresiones regulares.

##### table.whitelist

Similar a database.whitelist pero aplicado a tablas. debera colocarse el nombre qualificado de la tabla (nombrebase.nombretabla). Acepta expresiones regulares.

##### table.blacklist

Similar a database.blacklist pero aplicado a tablas. debera colocarse el nombre qualificado de la tabla (nombrebase.nombretabla). Acepta expresiones regulares.

##### column.blacklist

Similar a database.blacklist pero aplicado a columnas. debera colocarse el nombre qualificado de la columna (nombrebase.nombretabla.nombrecolumna). Acepta expresiones regulares.

##### column.truncate.to.length.chars

Indica a cuantos caracteres debera truncarse el valor de dicha columna durante el monitoreo de los eventos correspondientes a esa columan. Sustituir la palabra *length* por un número. Deberá colocarse el nombre qualificado de la columna (nombrebase.nombretabla.nombrecolumna). Acepta expresiones regulares.

##### column.mask.with.length.chars

Similar a column.truncate.to.length.chars pero en lugar de truncarlos sustituye los valores de las columnas por asteriscos. Bastante util para el manejo de passwords. Sustituir la palabra *length* por un numero. Deberá colocarse el nombre qualificado de la columna (nombrebase.nombretabla.nombrecolumna). Acepta expresiones regulares.

##### time.precision.mode

Representación del timestamp del evento, recomendable dejar **adaptive_time_microseconds** (default) ya que es el mas preciso.

##### decimal.handling.mode

Especifica como debe manejar los valores númericos el conector, el valor por defecto es **precise** el cual utiliza la clase de java java.math.BigDecimal, tambien esta el valor **double** que representa los datos en double, o **string**.

##### bigint.unsigned.handling.mode

Representación de los tipos de datos BIGINT UNSIGNED, por defecto utiliza long quien usa la clase java java.math.BigDecimal, cuando el tamaño supera 2^63 bits se recomienda colocar el valor **precise**.

##### include.schema.changes

Monitorea los cambios hechos al esquema de la base de datos. Por defecto es true.

##### include.query

Este booleano permite mostrar dentro del evento el query que provo dicho evento. Por defecto esta en false.

##### event.processing​.failure.handling.mode

Señala como debe actuar el conector ante excepciones ocasionadas por la deserialización de eventos binlog. Por defecto esta el fail el cual provoca que en cada excepcion el conector se detenga, tambien esta warn el cual solo alerta del evento y finalmente skip el cual hace saso omiso.

##### inconsistent.schema.handling.mode

Specifies how the connector should react to binlog events that relate to tables that are not present in internal schema representation (i.e. internal representation is not consistent with database).

##### max.queue.size

Tamaño maximo del bloque que almacenara los eventos antes de escribirlos en Kafka, el valor debe ser positivo (default: 8192).

##### max.batch.size

Tamaño del lote de eventos que deben ser procesados, este valor debe ser menor a max.queue.size

##### poll.interval.ms

Tiempo que el conector espera antes de procesar el siguiente lote de eventos, por default esta en 1 segundo, el valor debe estar en milliseconds.

##### connect.timeout.ms

Valor en milisegundos que el conector espera antes de declarar timeout al intentar conectarse a Mysql.