##################################################
#                                                #
#      Runit Mongo Debezium Connect 1.1          #
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
DEBEZIUM_CONNECT_NAME="mongodb-connector"
DEBEZIUM_CONNECT_DB_HOST="10.23.144.138"
DEBEZIUM_CONNECT_DB_PORT="3306"
DEBEZIUM_CONNECT_DB_USER="root"
DEBEZIUM_CONNECT_DB_PASS="abcd1234"
DEBEZIUM_CONNECT_DB_NAME="MyGuests"
DEBEZIUM_CONNECT_DB_ID="223344" # Alias
DEBEZIUM_CONNECT_SERVER_NAME="mysql-first"
DEBEZIUM_CONNECT_KAFKA_SERVERS="10.23.144.138:9092"
DEBEZIUM_CONNECT_KAFKA_TOPIC="schema-changes.MyGuests"

## Deploy this container if not exists
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

sleep 60

cat<<-EOF > $DEBEZIUM_CONNECT_NAME.json
{"name":
    "$DEBEZIUM_CONNECT_NAME",
    "config":{
        "connector.class":"io.debezium.connector.mongodb.MongoDbConnector",
        "mongodb.hosts":"$DEBEZIUM_CONNECT_DB_HOST",
        "mongodb.name":"$DEBEZIUM_CONNECT_DB_PORT",
        "mongodb.user":"$DEBEZIUM_CONNECT_DB_USER",
        "mongodb.password":"$DEBEZIUM_CONNECT_DB_PASS",
        "mongodb.authsource":"$DEBEZIUM_CONNECT_DB_ID",
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