#!/bin/bash

DEBEZIUM_CONNECT_NAME="mongodb-connector-2"
DEBEZIUM_CONNECT_DB_HOSTS="10.23.144.138:27017,10.23.144.139:27017"
DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME="10.23.144.138"
DEBEZIUM_CONNECT_ADVERTISED_PORT="8083"
DEBEZIUM_CONNECT_MONGO_NAME="mongo-second"
DEBEZIUM_CONNECT_DB_USER="amxga"
DEBEZIUM_CONNECT_DB_PASS="abcd1234"
DEBEZIUM_CONNECT_COLLECTION_WHITELIST="inventory[.]*"

cat<<-EOF > $DEBEZIUM_CONNECT_NAME.json
{"name":
    "$DEBEZIUM_CONNECT_NAME",
    "config": {
        "connector.class": "io.debezium.connector.mongodb.MongoDbConnector",
        "mongodb.hosts": "$DEBEZIUM_CONNECT_DB_HOSTS",
        "mongodb.name": "$DEBEZIUM_CONNECT_MONGO_NAME",
        "mongodb.user": "$DEBEZIUM_CONNECT_DB_USER",
        "mongodb.password": "$DEBEZIUM_CONNECT_DB_PASS",
        "collection.whitelist": "$DEBEZIUM_CONNECT_COLLECTION_WHITELIST"
    }
}
EOF

echo "[AMX $(date)] Set connector"
curl -i -X POST -H "Accept:application/json" \
    -H "Content-Type:application/json" $DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME:$DEBEZIUM_CONNECT_ADVERTISED_PORT/connectors/ \
    -d @$DEBEZIUM_CONNECT_NAME.json

rm -f $DEBEZIUM_CONNECT_NAME.json

curl -H "Accept:application/json" $DEBEZIUM_CONNECT_ADVERTISED_HOST_NAME:$DEBEZIUM_CONNECT_ADVERTISED_PORT/connectors/
