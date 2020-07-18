# Redis 5.0.5

Creación de imagen y despliegue de contenedor de Redis 5.0.5

## Prerequisitos

* Docker 1.13.X
* Virtual CentOS / Rhel
* Imagen dockeregistry.amovildigitalops.com/rhel7-atomic

## Desarrollo

Clonamos el directorio con los archivos necesarios para la construccion de la imagen de Redis.

```bash
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/redis-5.0.5.git /opt/redis
```

Creamos la imagen de Redis

```bash
docker build -t dockeregistry.amovildigitalops.com/atomic-rhel7-redis:5.0.5-v2 /opt/redis/docker
```

Para realizar el despliegue del contenedor, hacemos uso de los siguientes comandos: 

**NOTA: Levantar el contenedor como** *privileged* **permite al entrypoint cambiar una configuración para un mejor funcionamiento de redis, sin embargo, aún sin esta modificación redis funciona correctamente.**

> No olvidar la instrucción **sysctl -w net.core.somaxconn=65535** en cada servidor donde se despliegue un servicio redis.

Consultar archivos runits en el directorio [cluster](cluster/).

### Nodo master

```sh
#####################################################
#                                                   #
#           Runit Redis Master 5.0.5                #
#                                                   #
#####################################################

#Dont forget: sysctl -w net.core.somaxconn=65535

REDIS_CONTAINER="redis.master.service"
REDIS_PASSWORD="abcd1234"
MEMORY=10240m
REDIS_MEMORY=4096m
REDIS_EXTERNAL_IP= #Ip del servidor donde se desplegara redis
REDIS_EXTERNAL_PORT= #Puerto por el que se anunciara la instancia de redis

mkdir -p /var/containers/$REDIS_CONTAINER/{var/log/redis/,var/lib/redis/}
chown 52872:root -R /var/containers/$REDIS_CONTAINER/{var/log/redis/,var/lib/redis/}

docker run -td --privileged --name  $REDIS_CONTAINER -p 6379:6379 \
        --cap-add sys_resource \
        --health-cmd='/sbin/docker-health-check.sh' \
        --sysctl=net.core.somaxconn="65535" \
        --ulimit nproc=1048576:1048576 \
        --memory-swappiness=0 \
        --restart unless-stopped \
        --memory=${MEMORY} \
        --health-interval=10s \
        -v /etc/localtime:/etc/localtime:ro \
        --volume=/usr/share/zoneinfo:/usr/share/zoneinfo:ro \
        -v /var/containers/$REDIS_CONTAINER/var/lib/redis/:/var/lib/redis/:z \
        -e TZ=America/Mexico_City \
        -e REDIS_REPLICA_ANNOUNCE_IP=$REDIS_EXTERNAL_IP \
        -e REDIS_REPLICA_ANNOUNCE_PORT=$REDIS_EXTERNAL_PORT \
        -e REDIS_REQUIREPASS=$REDIS_PASSWORD \
        -e REDIS_ACTIVEREHASHING="yes" \
        -e REDIS_AOF_LOAD_TRUNCATED="yes" \
        -e REDIS_AOF_REWRITE_INCREMENTAL_FSYNC="yes" \
        -e REDIS_APPENDFILENAME="appendonly.aof" \
        -e REDIS_APPENDFSYNC="everysec" \
        -e REDIS_APPENDONLY="yes" \
        -e REDIS_AUTO_AOF_REWRITE_MIN_SIZE="64mb" \
        -e REDIS_AUTO_AOF_REWRITE_PERCENTAGE="100" \
        -e REDIS_CLIENT_OUTPUT_BUFFER_LIMIT="normal 0 0 0;pubsub 32mb 8mb 60;replica 256mb 64mb 60" \
        -e REDIS_DATABASES="16" \
        -e REDIS_HASH_MAX_ZIPLIST_ENTRIES="512" \
        -e REDIS_HASH_MAX_ZIPLIST_VALUE="64" \
        -e REDIS_HLL_SPARSE_MAX_BYTES="3000" \
        -e REDIS_HZ="10" \
        -e REDIS_LATENCY_MONITOR_THRESHOLD="0" \
        -e REDIS_LIST_COMPRESS_DEPTH="0" \
        -e REDIS_LIST_MAX_ZIPLIST_SIZE="-2" \
        -e REDIS_LOGLEVEL="notice" \
        -e REDIS_LUA_TIME_LIMIT="5000" \
        -e REDIS_MAXMEMORY="512m" \
        -e REDIS_MAXMEMORY_POLICY="allkeys-lru" \
        -e REDIS_NO_APPENDFSYNC_ON_REWRITE="no" \
        -e REDIS_NOTIFY_KEYSPACE_EVENTS='""' \
        -e REDIS_PROTECTED_MODE="yes" \
        -e REDIS_RDBCHECKSUM="yes" \
        -e REDIS_RDBCOMPRESSION="yes" \
        -e REDIS_REPL_DISABLE_TCP_NODELAY="no" \
        -e REDIS_REPL_DISKLESS_SYNC="no" \
        -e REDIS_REPL_DISKLESS_SYNC_DELAY="5" \
        -e REDIS_SET_MAX_INTSET_ENTRIES="512" \
        -e REDIS_SLAVE_READ_ONLY="yes" \
        -e REDIS_REPLICA_SERVE_STALE_DATA="yes" \
        -e REDIS_SLOWLOG_LOG_SLOWER_THAN="1000" \
        -e REDIS_SLOWLOG_MAX_LEN="128" \
        -e REDIS_STOP_WRITES_ON_BGSAVE_ERROR="yes" \
        -e REDIS_SUPERVISED="no" \
        -e REDIS_TCP_BACKLOG="511" \
        -e REDIS_TCP_KEEPALIVE="300" \
        -e REDIS_TIMEOUT="0" \
        -e REDIS_ZSET_MAX_ZIPLIST_ENTRIES="128" \
        -e REDIS_ZSET_MAX_ZIPLIST_VALUE="64" \
        dockeregistry.amovildigitalops.com/atomic-rhel7-redis:5.0.5-v2
```

### Nodo Slave

```sh
#####################################################
#                                                   #
#           Runit Redis Slave 5.0.5                 #
#                                                   #
#####################################################

#Dont forget: sysctl -w net.core.somaxconn=65535

REDIS_CONTAINER="redis.slave.service"
REDIS_PASSWORD="abcd1234"
MEMORY=10240m
REDIS_MEMORY=4096m
REDIS_EXTERNAL_IP= #Ip del servidor donde se desplegara redis
REDIS_EXTERNAL_PORT= #Puerto por el que se anunciara la instancia de redis
REDIS_MASTER_IP= #Ip del Redis Master
REDIS_MASTER_PORT= #Puerto del Redis Master
REDIS_MASTER_PASSWORD= #Password del Redis Master
REDIS_REPLICA_PRIORITY= #Prioridad para ser promovido a Master (Se considera primero a los nodos con menor prioridad)

mkdir -p /var/containers/$REDIS_CONTAINER/{var/log/redis/,var/lib/redis/}
chown 52872:root -R /var/containers/$REDIS_CONTAINER/{var/log/redis/,var/lib/redis/}

docker run -td --privileged --name  $REDIS_CONTAINER -p 6379:6379 \
        --cap-add sys_resource \
        --health-cmd='/sbin/docker-health-check.sh' \
        --sysctl=net.core.somaxconn="65535" \
        --ulimit nproc=1048576:1048576 \
        --memory-swappiness=0 \
        --restart unless-stopped \
        --memory=${MEMORY} \
        --health-interval=10s \
        -v /etc/localtime:/etc/localtime:ro \
        --volume=/usr/share/zoneinfo:/usr/share/zoneinfo:ro \
        -v /var/containers/$REDIS_CONTAINER/var/lib/redis/:/var/lib/redis/:z \
        -e TZ=America/Mexico_City \
        -e REDIS_REPLICA_ANNOUNCE_IP=$REDIS_EXTERNAL_IP \
        -e REDIS_REPLICA_ANNOUNCE_PORT=$REDIS_EXTERNAL_PORT \
        -e REDIS_REPLICAOF="$REDIS_MASTER_IP $REDIS_MASTER_PORT" \
        -e REDIS_MASTERAUTH=$REDIS_MASTER_PASSWORD \
        -e REDIS_REPLICA_PRIORITY=$REDIS_REPLICA_PRIORITY \
        -e REDIS_REQUIREPASS=$REDIS_PASSWORD \
        -e REDIS_ACTIVEREHASHING="yes" \
        -e REDIS_AOF_LOAD_TRUNCATED="yes" \
        -e REDIS_AOF_REWRITE_INCREMENTAL_FSYNC="yes" \
        -e REDIS_APPENDFILENAME="appendonly.aof" \
        -e REDIS_APPENDFSYNC="everysec" \
        -e REDIS_APPENDONLY="yes" \
        -e REDIS_AUTO_AOF_REWRITE_MIN_SIZE="64mb" \
        -e REDIS_AUTO_AOF_REWRITE_PERCENTAGE="100" \
        -e REDIS_CLIENT_OUTPUT_BUFFER_LIMIT="normal 0 0 0;pubsub 32mb 8mb 60;replica 256mb 64mb 60" \
        -e REDIS_DATABASES="16" \
        -e REDIS_HASH_MAX_ZIPLIST_ENTRIES="512" \
        -e REDIS_HASH_MAX_ZIPLIST_VALUE="64" \
        -e REDIS_HLL_SPARSE_MAX_BYTES="3000" \
        -e REDIS_HZ="10" \
        -e REDIS_LATENCY_MONITOR_THRESHOLD="0" \
        -e REDIS_LIST_COMPRESS_DEPTH="0" \
        -e REDIS_LIST_MAX_ZIPLIST_SIZE="-2" \
        -e REDIS_LOGLEVEL="notice" \
        -e REDIS_LUA_TIME_LIMIT="5000" \
        -e REDIS_MAXMEMORY="512m" \
        -e REDIS_MAXMEMORY_POLICY="allkeys-lru" \
        -e REDIS_NO_APPENDFSYNC_ON_REWRITE="no" \
        -e REDIS_NOTIFY_KEYSPACE_EVENTS='""' \
        -e REDIS_PROTECTED_MODE="yes" \
        -e REDIS_RDBCHECKSUM="yes" \
        -e REDIS_RDBCOMPRESSION="yes" \
        -e REDIS_REPL_DISABLE_TCP_NODELAY="no" \
        -e REDIS_REPL_DISKLESS_SYNC="no" \
        -e REDIS_REPL_DISKLESS_SYNC_DELAY="5" \
        -e REDIS_SET_MAX_INTSET_ENTRIES="512" \
        -e REDIS_SLAVE_READ_ONLY="yes" \
        -e REDIS_REPLICA_SERVE_STALE_DATA="yes" \
        -e REDIS_SLOWLOG_LOG_SLOWER_THAN="1000" \
        -e REDIS_SLOWLOG_MAX_LEN="128" \
        -e REDIS_STOP_WRITES_ON_BGSAVE_ERROR="yes" \
        -e REDIS_SUPERVISED="no" \
        -e REDIS_TCP_BACKLOG="511" \
        -e REDIS_TCP_KEEPALIVE="300" \
        -e REDIS_TIMEOUT="0" \
        -e REDIS_ZSET_MAX_ZIPLIST_ENTRIES="128" \
        -e REDIS_ZSET_MAX_ZIPLIST_VALUE="64" \
        dockeregistry.amovildigitalops.com/atomic-rhel7-redis:5.0.5-v2
```

### Nodo sentinel

```sh
#####################################################
#                                                   #
#           Runit Redis Sentinel 5.0.5              #
#                                                   #
#####################################################

#Dont forget: sysctl -w net.core.somaxconn=65535

REDIS_CONTAINER="redis.sentinel.service"
REDIS_PASSWORD="abcd1234"
MEMORY=10240m
REDIS_MEMORY=4096m
REDIS_PORT=26379 #Puerto de la instancia sentinel
REDIS_EXTERNAL_IP= #Ip del servidor donde se desplegara redis
REDIS_EXTERNAL_PORT= #Puerto por el que se anunciara la instancia de redis
REDIS_MASTER_IP= #Ip del Redis Master
REDIS_MASTER_PORT= #Puerto del Redis Master
REDIS_MASTER_PASSWORD= #Password del Redis Master
REDIS_MASTER_ALIAS= #Alias que se le otorga al Redis Master
REDIS_SENTINEL_QUANTUM= #Numero de Redis Sentinel que tienen que estar de acuerdo para promover a un nuevo nodo como Master (Como minimo debe ser dos)
REDIS_SENTINEL_FAILOVER_TIMEOUT= #Tiempo en milisegundos para determinar el nodo master esta caido despues del ultimo ping

mkdir -p /var/containers/$REDIS_CONTAINER/{var/log/redis/,var/lib/redis/}
chown 52872:root -R /var/containers/$REDIS_CONTAINER/{var/log/redis/,var/lib/redis/}

docker run -td --privileged --name  $REDIS_CONTAINER -p 26379:26379 \
        --cap-add sys_resource \
        --health-cmd='/sbin/docker-health-check.sh' \
        --sysctl=net.core.somaxconn="65535" \
        --ulimit nproc=1048576:1048576 \
        --memory-swappiness=0 \
        --restart unless-stopped \
        --memory=${MEMORY} \
        --health-interval=10s \
        -v /etc/localtime:/etc/localtime:ro \
        --volume=/usr/share/zoneinfo:/usr/share/zoneinfo:ro \
        -v /var/containers/$REDIS_CONTAINER/var/lib/redis/:/var/lib/redis/:z \
        -e TZ=America/Mexico_City \
        -e REDIS_SENTINEL_ANNOUNCE_IP=$REDIS_EXTERNAL_IP \
        -e REDIS_SENTINEL_ANNOUNCE_PORT=$REDIS_EXTERNAL_PORT \
        -e REDIS_SENTINEL_MONITOR="$REDIS_MASTER_ALIAS $REDIS_MASTER_IP $REDIS_MASTER_PORT $REDIS_SENTINEL_QUANTUM" \
        -e REDIS_SENTINEL_FAILOVER_TIMEOUT="$REDIS_MASTER_ALIAS $REDIS_SENTINEL_FAILOVER_TIMEOUT" \
        -e REDIS_SENTINEL_AUTH_PASS="$REDIS_MASTER_ALIAS $REDIS_MASTER_PASSWORD" \
        -e REDIS_PORT=$REDIS_PORT \
        -e REDIS_REQUIREPASS=$REDIS_PASSWORD \
        -e REDIS_ACTIVEREHASHING="yes" \
        -e REDIS_AOF_LOAD_TRUNCATED="yes" \
        -e REDIS_AOF_REWRITE_INCREMENTAL_FSYNC="yes" \
        -e REDIS_APPENDFILENAME="appendonly.aof" \
        -e REDIS_APPENDFSYNC="everysec" \
        -e REDIS_APPENDONLY="yes" \
        -e REDIS_AUTO_AOF_REWRITE_MIN_SIZE="64mb" \
        -e REDIS_AUTO_AOF_REWRITE_PERCENTAGE="100" \
        -e REDIS_CLIENT_OUTPUT_BUFFER_LIMIT="normal 0 0 0;pubsub 32mb 8mb 60;replica 256mb 64mb 60" \
        -e REDIS_DATABASES="16" \
        -e REDIS_HASH_MAX_ZIPLIST_ENTRIES="512" \
        -e REDIS_HASH_MAX_ZIPLIST_VALUE="64" \
        -e REDIS_HLL_SPARSE_MAX_BYTES="3000" \
        -e REDIS_HZ="10" \
        -e REDIS_LATENCY_MONITOR_THRESHOLD="0" \
        -e REDIS_LIST_COMPRESS_DEPTH="0" \
        -e REDIS_LIST_MAX_ZIPLIST_SIZE="-2" \
        -e REDIS_LOGLEVEL="notice" \
        -e REDIS_LUA_TIME_LIMIT="5000" \
        -e REDIS_MAXMEMORY="512m" \
        -e REDIS_MAXMEMORY_POLICY="allkeys-lru" \
        -e REDIS_NO_APPENDFSYNC_ON_REWRITE="no" \
        -e REDIS_NOTIFY_KEYSPACE_EVENTS='""' \
        -e REDIS_PROTECTED_MODE="yes" \
        -e REDIS_RDBCHECKSUM="yes" \
        -e REDIS_RDBCOMPRESSION="yes" \
        -e REDIS_REPL_DISABLE_TCP_NODELAY="no" \
        -e REDIS_REPL_DISKLESS_SYNC="no" \
        -e REDIS_REPL_DISKLESS_SYNC_DELAY="5" \
        -e REDIS_SET_MAX_INTSET_ENTRIES="512" \
        -e REDIS_SLAVE_READ_ONLY="yes" \
        -e REDIS_REPLICA_SERVE_STALE_DATA="yes" \
        -e REDIS_SLOWLOG_LOG_SLOWER_THAN="1000" \
        -e REDIS_SLOWLOG_MAX_LEN="128" \
        -e REDIS_STOP_WRITES_ON_BGSAVE_ERROR="yes" \
        -e REDIS_SUPERVISED="no" \
        -e REDIS_TCP_BACKLOG="511" \
        -e REDIS_TCP_KEEPALIVE="300" \
        -e REDIS_TIMEOUT="0" \
        -e REDIS_ZSET_MAX_ZIPLIST_ENTRIES="128" \
        -e REDIS_ZSET_MAX_ZIPLIST_VALUE="64" \
        dockeregistry.amovildigitalops.com/atomic-rhel7-redis:5.0.5-v2
```

**NOTA**: Si en el archivo por defecto si se omite alguna de las variables **TIME_DUMP** y **LINES_DUMP** Redis **NO** hará un volcado de la base de datos en disco, en el tipo de persistencia RDB.
Donde:

* **TIME_DUMP**: N segundos para volcar la base de datos en disco.
* **LINES_DUMP**: M mínimas inserciones escritas en la base para volcarla.

En la configuración quedará algo como esto: 

```sh
save <TIME_DUMP> <LINES_DUMP>

save 60 100
```

>Después de cada 60 segundos y 100 líneas escritas se hará el volcado de la base.

**NOTA**: Para levantar la instancia de Redis con autenticacion, es necesario especificar la contraseña en la variable de entorno **REDIS_PASSWORD**.

**NOTA**: Para establecer el número de clientes que pueden ser atendidos por Redis de manera concurrente utilizamos la variable **MAX_CLIENTS**, por defecto Redis establece este valor en 10000. Es importante señalar que Redis verifica con el núcleo cuál es el número máximo de descriptores de archivos que podemos abrir (se verifica el límite flexible ). Si el límite es menor que el número máximo de clientes que queremos manejar, más 32 (que es el número de descriptores de archivo que Redis reserva para usos internos), Redis modifica el número de clientes máximo para que coincida con la cantidad de clientes que son realmente capaces de manejar por debajo del límite actual del sistema operativo.

**NOTA**: AOF es un tipo de persistencia que provee Redis con la finalidad de lograr un rendimiento similar al de los gestores de bases de datos como Postgres o Mysql, a diferencia de RDB, AOF realiza un volcado de la base de datos cada segundo en comparación con RDB quien lo hace cada cierta "captura" (es decir cada vez que se cuple los atributos **TIME_DUMP** y **LINES_DUMP** de la directiva *save*). 
Con AOF se viene a solucionar el siguiente problema, si su computadora que ejecuta Redis se detiene, su línea de alimentación falla o accidentalmente kill -9 su instancia, los últimos datos escritos en Redis se perderán, sin embargo con AOF cada vez que Redis reciba un comando que cambie el conjunto de datos (por ejemplo, SET ), lo agregará al AOF y cuando reinicie Redis, este volverá a reproducir el AOF para reconstruir el estado de la base de datos.
Para activar esta directiva el valor de la variable **APPENDONLY** debe ser **yes**, su valor por defecto es no.

**NOTA**: Si se tiene establecido tanto la persistencia **RDB** como **AOF** cuando Redis reinicie, el archivo AOF (en caso de existir) se usará para reconstruir el conjunto de datos original, ya que se garantiza que será el más completo.

### Demás variables

* REDIS_ACTIVEREHASHING="yes" *# Libera memoria lo más rápido posible*
* REDIS_AOF_LOAD_TRUNCATED="yes" *# Carga el archivo AOF*
* REDIS_AOF_REWRITE_INCREMENTAL_FSYNC="yes" *# Reescribe el archivo y reinicia el fsync*
* REDIS_APPENDFILENAME="appendonly.aof" *# Nombre del archivo AOF (default: "appendonly.aof")*
* REDIS_APPENDFSYNC="everysec" *# Todo el tiempo está escribiendo en el archivo aof sin importar que exista algo o no en el buffer (default: "everysec")*
* REDIS_APPENDONLY="no" *# Habilita el modo de escritura en archivo append only (default: "no")*
* REDIS_AUTO_AOF_REWRITE_MIN_SIZE="64mb" *# Tamaño mínimo para reescribir en el archivo aof (default: "32mb")*
* REDIS_AUTO_AOF_REWRITE_PERCENTAGE="100" *# Porcetnaje de reescritura (0 para desactivar)*
* REDIS_CLIENT_OUTPUT_BUFFER_LIMIT="normal 0 0 0;pubsub 32mb 8mb 60;replica 256mb 64mb 60" *# Límite de buffer de salida a cliente*
* REDIS_DATABASES="16" *# Número de bd's*
* REDIS_HASH_MAX_ZIPLIST_ENTRIES="512" *# Entradas máximas en listas zip*
* REDIS_HASH_MAX_ZIPLIST_VALUE="64" *# Valor máximo de lista zip*
* REDIS_HLL_SPARSE_MAX_BYTES="3000" *# Límite en bytes de HyperLogLog (3000 recomendado)*
* REDIS_HZ="10" *# Llamadas máximas a tareas internas de redis (Recomendado 10 para no sobrecargar cpu)*
* REDIS_LATENCY_MONITOR_THRESHOLD="0" *# Monitor de latencia (desactivado en 0, recomendado al no ser vital)*
* REDIS_LIST_COMPRESS_DEPTH="0" *# Profundidad de compresión*
* REDIS_LIST_MAX_ZIPLIST_SIZE="-2" *# Número de entradas permitidas por lista interna*
  * -5: max size: 64 Kb  <-- not recommended for normal workloads
  * -4: max size: 32 Kb  <-- not recommended
  * -3: max size: 16 Kb  <-- probably not recommended
  * -2: max size: 8 Kb   <-- good
  * -1: max size: 4 Kb   <-- good
* REDIS_LOGLEVEL="notice" *# Nivel de logging*
* REDIS_LUA_TIME_LIMIT="5000" *# Límite tiempo LUA*
* REDIS_MAXMEMORY="512m" *# Uso máximo de memoria en bytes*
* REDIS_MAXMEMORY_POLICY="allkeys-lru" *# Política de memoria máxima*
* REDIS_NO_APPENDFSYNC_ON_REWRITE="no" *# Evita que fsync sea llamado en el proceso principal*
* REDIS_NOTIFY_KEYSPACE_EVENTS='""' *# Desactiva notificaciones*
* REDIS_PROTECTED_MODE="yes" *# Capa de seguridad que protege a las instancias redis de dejar conexiones abiertas*
* REDIS_RDBCHECKSUM="yes" *# Vuelve el formato rbd menos suceptible a estar corrupto*
* REDIS_RDBCOMPRESSION="yes" *# Habilita compresión rbd*
* REDIS_REPL_DISABLE_TCP_NODELAY="no" *# Si se habilita, limita el ancho de banda y podría repercutir en la data sincronizada*
* REDIS_REPL_DISKLESS_SYNC="no" *# Habilitar en discos de baja velocidad*
* REDIS_REPL_DISKLESS_SYNC_DELAY="5" *# Delay en la sincronización dsikless, sólo si ésta se activó*
* REDIS_SET_MAX_INTSET_ENTRIES="512" *# Tamaño de memoria especial para encoding*
* REDIS_SLAVE_READ_ONLY="yes" *# Replica es read only (valor por defecto)*
* REDIS_REPLICA_SERVE_STALE_DATA="yes" *# En caso de que la réplica pierda conexión con el máster, ésta sigue sirviendo data a los clientes*
* REDIS_SLOWLOG_LOG_SLOWER_THAN="1000" *# Tiempo en microsegundos para slowlog*
* REDIS_SLOWLOG_MAX_LEN="128" *# Longitod máxima para slowlog*
* REDIS_STOP_WRITES_ON_BGSAVE_ERROR="yes" *# Detiene escritura en caso de un error en disco*
* REDIS_SUPERVISED="no" *# Deshabilita interacción de supervisión*
  * supervised upstart - signal upstart by putting Redis into SIGSTOP mode
  * supervised systemd - signal systemd by writing READY=1 to $NOTIFY_SOCKET
  * supervised auto    - detect upstart or systemd method based on UPSTART_JOB or NOTIFY_SOCKET environment variables
* REDIS_TCP_BACKLOG="511" *# Valor para backlog*
* REDIS_TCP_KEEPALIVE="300" *# Keepalive en milisegundos*
* REDIS_TIMEOUT="0" *# Timeout desactivado*
* REDIS_ZSET_MAX_ZIPLIST_ENTRIES="128" *# Entradas máximas ziplist*
* REDIS_ZSET_MAX_ZIPLIST_VALUE="64" *# Valor de entradas ziplist*

## Archivo Python para insertar datos

Los archivos python ubicados en este repositorio permiten simular grandes inserciones, para hacer uso de dichos archivos es importante tener instalado el módulo de Redis

```bash
pip install redis
```

Y la ejecución del script se es de la siguiente forma

```bash
python main.py --host 127.0.0.1 --port 6379 --password mypassword -i 500 -db 0
```

Donde:

* **--host**: Host donde se encuentra desplegado Redis (valor defecto: 127.0.0.1)
* **--port**: Puerto donde escucha la instancia de Redis (valor defecto: 6379)
* **--password**: Password para conectarse a la base de datos (valor defecto: *Ninguno*)
* **-db**: Index de la base de datos (valor defecto: 0)
* **-i**: Número de datos a insertar (valor defecto: 1)