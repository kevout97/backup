##########################################
#                                        #
#        Runit Mongo Master 3.6          #
#                                        #
##########################################

# Dont forget disable Transparent Huge Pages (https://docs.mongodb.com/v3.6/tutorial/transparent-huge-pages/)
## THP_PATH=$(find /sys/kernel/ -name "transparent_hugepage")
## echo 'never' > $THP_PATH/enabled
## echo 'never' > $THP_PATH/defrag 

MONGO_CONTAINER="mongo.master" # Nombre del contenedor
MONGO_PORT="27017" # Puerto por el que correrá Mongo
MONGO_USER="mongoadmin" # Usuario administrador
MONGO_PASSWORD="4xCHHcRZZLv7" # Password del usario administrador
MONGO_REPLICATION_NAME="mongoJitsi" # Nombre del cluster de Mongo
MONGO_EXTERNAL_PORT="27017" # Puerto externo por el que se expondra Mongo 
MONGO_EXTERNAL_IP="172.26.90.151" # Ip del servidor, debe ser accesible por los otros nodos

mkdir -p /var/containers/$MONGO_CONTAINER/{etc/mongo/,var/lib/mongodb/data,opt/mongodb/,var/log/mongodb/}

cat<<-EOF > /var/containers/$MONGO_CONTAINER/etc/mongo/mongod.conf
# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb/data
  journal:
    enabled: true
  wiredTiger:
    engineConfig:
      cacheSizeGB: 15.5

# where to write logging data.
systemLog:
  verbosity: 5
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
  component:
    accessControl:
      verbosity: 5
    command:
      verbosity: 5
    query:
      verbosity: 5
    replication:
      verbosity: 5

# network interfaces
net:
  port: $MONGO_PORT
  bindIpAll: true

# how the process runs
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
EOF

chown 184:184 -R /var/containers/$MONGO_CONTAINER

## Deploy Mongo container (master)
docker run -itd --name $MONGO_CONTAINER --restart=always \
    --memory-swappiness=0 \
    -p $MONGO_EXTERNAL_PORT:$MONGO_PORT \
    -v /var/containers/$MONGO_CONTAINER/var/lib/mongodb/data:/var/lib/mongodb/data:z \
    -v /var/containers/$MONGO_CONTAINER/opt/mongodb/:/opt/mongodb/:z \
    -v /var/containers/$MONGO_CONTAINER/etc/mongo:/etc/mongo:z \
    -v /var/containers/$MONGO_CONTAINER/var/log/mongodb/:/var/log/mongodb/:z \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -e "TZ=America/Mexico_City" \
    registry.redhat.io/rhscl/mongodb-36-rhel7 mongod --config /etc/mongo/mongod.conf

sleep 10

## Configurung key to replication
yum install openssl -y
openssl rand -base64 756 > /var/containers/$MONGO_CONTAINER/opt/mongodb/mongo-keyfile
chmod 400 /var/containers/$MONGO_CONTAINER/opt/mongodb/mongo-keyfile && chown 184:184 /var/containers/$MONGO_CONTAINER/opt/mongodb/mongo-keyfile

cat<<-EOF >> /var/containers/$MONGO_CONTAINER/etc/mongo/mongod.conf
security:
  keyFile: /opt/mongodb/mongo-keyfile
  authorization: 'enabled'

replication:
  replSetName: $MONGO_REPLICATION_NAME
EOF

chown 184:184 -R /var/containers/$MONGO_CONTAINER

docker restart $MONGO_CONTAINER

sleep 15
## Configuring first user
docker exec -it $MONGO_CONTAINER mongo admin --eval "rs.initiate({_id : '$MONGO_REPLICATION_NAME',version: 1,members: [{ _id : 0, host : '$MONGO_EXTERNAL_IP:$MONGO_EXTERNAL_PORT' }]})"
echo ""; echo ""
sleep 15
docker exec -it $MONGO_CONTAINER mongo admin --eval "rs.status()"
echo ""; echo ""
docker exec -it $MONGO_CONTAINER mongo admin --eval "db.createUser({user:'$MONGO_USER',pwd:'$MONGO_PASSWORD',roles:[{role:'root',db:'admin'}]})"
echo ""; echo ""
echo "[CS $(date)] You should share this key with others nodes"
echo ""
cat /var/containers/$MONGO_CONTAINER/opt/mongodb/mongo-keyfile
echo ""

## Comando para aggregar un nuevo nodo
# rs.add("ip_nodo:puerto_nodo")