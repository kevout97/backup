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
docker build -t dockeregistry.amovildigitalops.com/atomic-rhel7-redis:5.0.5 /opt/redis
```

Para realizar el despliegue del contenedor, hacemos uso de los siguientes comandos: 

**NOTA: Levantar el contenedor como** *privileged* **permite al entrypoint cambiar una configuración para un mejor funcionamiento de redis, sin embargo, aún sin esta modificación redis funciona correctamente.**

```bash
#!/bin/bash

#Dont forget: sysctl -w net.core.somaxconn=65535

name=redis-service
puerto=6379
redisp="lApQeO8357MvImoX"
memory=10240m
redis_memory=4096m

docker rm -f $name

mkdir -p /var/containers/$name/{var/log/redis/,var/lib/redis/,usr/local/etc/redis/} /var/containers/$name/var/lib/redis/data
chown 52872:root -R /var/containers/$name/{var/log/redis/,var/lib/redis/,usr/local/etc/redis/}

docker run -td --privileged --name  $name  -p 6379:6379 \
        --cap-add sys_resource \
        -v /etc/localtime:/etc/localtime:ro \
        --health-cmd='/sbin/docker-health-check.sh' \
        --sysctl=net.core.somaxconn="65535" \
        --volume=/usr/share/zoneinfo:/usr/share/zoneinfo:ro \
        --ulimit nproc=1048576:1048576 \
        --memory-swappiness=0 \
        --restart unless-stopped \
        --memory=${memory} \
        --health-interval=10s \
        -v /etc/localtime:/etc/localtime:ro \
        -v /var/containers/$name/var/lib/redis/:/var/lib/redis/:z \
        -e REDIS_REQUIREPASS=$redisp \
        -e TZ=America/Mexico_City \
        -e REDIS_SAVE="60 100;300 1;60 10000" \
        -e REDIS_ACTIVEREHASHING="yes" \
        -e REDIS_AOF_LOAD_TRUNCATED="yes" \
        -e REDIS_AOF_REWRITE_INCREMENTAL_FSYNC="yes" \
        -e REDIS_APPENDFILENAME="appendonly.aof" \
        -e REDIS_APPENDFSYNC="everysec" \
        -e REDIS_APPENDONLY="no" \
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
    dockeregistry.amovildigitalops.com/atomic-rhel7-redis:5.0.5
```


**NOTA**: Si en el archivo

**NOTA**: Por defecto si se omite alguna de las variables **TIME_DUMP** y **LINES_DUMP** Redis **NO** hará un volcado de la base de datos en disco, en el tipo de persistencia RDB.
Donde:
* **TIME_DUMP**: N segundos para volcar la base de datos en disco.
* **LINES_DUMP**: M mínimas inserciones escritas en la base para volcarla.

En la configuración quedará algo como esto: 

save **TIME_DUMP** **LINES_DUMP**

save 60 100 *Después de cada 60 segundos y 100 líneas escritas se hará el volcado de la base.*

**NOTA**: Para levantar la instancia de Redis con autenticacion, es necesario especificar la contraseña en la variable de entorno **REDIS_PASSWORD**.

**NOTA**: Para establecer el número de clientes que pueden ser atendidos por Redis de manera concurrente utilizamos la variable **MAX_CLIENTS**, por defecto Redis establece este valor en 10000. Es importante señalar que Redis verifica con el núcleo cuál es el número máximo de descriptores de archivos que podemos abrir (se verifica el límite flexible ). Si el límite es menor que el número máximo de clientes que queremos manejar, más 32 (que es el número de descriptores de archivo que Redis reserva para usos internos), Redis modifica el número de clientes máximo para que coincida con la cantidad de clientes que son realmente capaces de manejar por debajo del límite actual del sistema operativo.

**NOTA**: AOF es un tipo de persistencia que provee Redis con la finalidad de lograr un rendimiento similar al de los gestores de bases de datos como Postgres o Mysql, a diferencia de RDB, AOF realiza un volcado de la base de datos cada segundo en comparación con RDB quien lo hace cada cierta "captura" (es decir cada vez que se cuple los atributos **TIME_DUMP** y **LINES_DUMP** de la directiva *save*). 
Con AOF se viene a solucionar el siguiente problema, si su computadora que ejecuta Redis se detiene, su línea de alimentación falla o accidentalmente kill -9 su instancia, los últimos datos escritos en Redis se perderán, sin embargo con AOF cada vez que Redis reciba un comando que cambie el conjunto de datos (por ejemplo, SET ), lo agregará al AOF y cuando reinicie Redis, este volverá a reproducir el AOF para reconstruir el estado de la base de datos.
Para activar esta directiva el valor de la variable **APPENDONLY** debe ser **yes**, su valor por defecto es no.

**NOTA**: Si se tiene establecido tanto la persistencia **RDB** como **AOF** cuando Redis reinicie, el archivo AOF (en caso de existir) se usará para reconstruir el conjunto de datos original, ya que se garantiza que será el más completo.

### Archivo Python

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