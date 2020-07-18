##########################################
#                                        #
#        Runit Mongo Slave 3.6           #
#                                        #
##########################################

# Dont forget disable Transparent Huge Pages (https://docs.mongodb.com/v3.6/tutorial/transparent-huge-pages/)
## THP_PATH=$(find /sys/kernel/ -name "transparent_hugepage")
## echo 'never' > $THP_PATH/enabled
## echo 'never' > $THP_PATH/defrag 

MONGO_CONTAINER="mongo.slave" # Nombre del contenedor
MONGO_PORT="27017" # Puerto por el que correrar Mongo
MONGO_REPLICATION_NAME="mongoJitsi" # Nombre del cluster
MONGO_EXTERNAL_PORT="27017" # Puerto externo por el que se expondra Mongo 
MONGO_EXTERNAL_IP="172.26.90.153" # Ip del servidor, debe ser accesible por los otros nodos

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

security:
  keyFile: /opt/mongodb/mongo-keyfile
  authorization: 'enabled'

replication:
  replSetName: $MONGO_REPLICATION_NAME
EOF

## Configurung key to replication
### Key generada en el Nodo Master
cat<<-EOF > /var/containers/$MONGO_CONTAINER/opt/mongodb/mongo-keyfile
MIIhX85veSlFMeuaE6vECDx92IdnP4ILW6Bk5o3IPA42x4JUKJbi8LyPx23LtD2S
5puTAf3jQ3FTUdlLsx9IOKvUhNJZh1yl5sIGK5lHP67PKROe8RIsP6m1+7hlWhr8
ZPRCk3mdwoex5lN71FkuJRbTz4//dALUNTrzFXgJVxXzLRH8Cf+U2/uQLbbS/7EO
tQYg/WMXyIx3C1/CsmWDZZ9kSac3Yb3zcp2tJEGnu3w9tbk0zaj7pRhktqY7oMOr
H3/8HuIEAdNNtz/jayhkTRVGIdvi47mQ4A31QEs3Gx4vhcMhuvYsRMqEelWHQw2I
Qfvfq/+2Nyl4mRrlbrQqum5cwAKFYfnjsET+7ZNNDtJd8NS2Nr6F4loSBw+ePyhe
IdqgcC81VginG4Y1yTArI5GaKEMcjnrAtkTNnYKrVkWhXkkVxE7EoQTRV6GYTq+1
DhzX+/n15YFZpx/y044EPhKVlw8vJ5kNm6EZe0bW+v7hKGn1vpGBEkmc5tenqvQt
fFZOdU3ydeoB4zwu0ojVGKZzdAwZs3GbxA+VJeg6v+nUDZZ9lv8a1aEXssBR/ucC
g9W+n9di4yT21N4giIrHkUgweNdhV/NiaG8mehtg7Fsyv9OwmH1m68tms0FJVRAv
1i8cahH67ESMWPScipe+Ak8/zk6Z46pfZomTUNzUemvV3Fqkgbsz5koG1XQszXhK
NEWBFSRjrADOufNMREgOk/8gLTP+r48cGpm5IJEw2o47Nx3uigYUhx86N9sh83in
/tJD1dKhI1KgdDGM4Gk8Tr+RAkxv24WHnINOz/7e/6jCo5YiICbwBExuctv6FVPq
jniD+p9HvZou0KkeQ3bx8idtTE/gGZJafg7JFT5gzzMKFlnM79qBolxLsnZnEsDv
YYg8ZRhC1f0nTnGgMmTouMhqCxZ/1Cct2tcNdWodVG69JfCX5bN93+OTfbxk1eHj
rLQaD/RCKfTEa++jXeEqt2VXbvxJnXmBUBjfXM1l1zjccTVt
EOF
chmod 400 /var/containers/$MONGO_CONTAINER/opt/mongodb/mongo-keyfile

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
echo "[CS $(date)] Slave Node started."
echo "[CS $(date)] You should run this command on your Master Node to include this node on your cluster."
echo "rs.add(\"$MONGO_EXTERNAL_IP:$MONGO_EXTERNAL_PORT\")"