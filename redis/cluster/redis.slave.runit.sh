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