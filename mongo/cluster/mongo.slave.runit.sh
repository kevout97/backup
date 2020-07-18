##########################################
#                                        #
#        Runit Mongo Slave 3.6           #
#                                        #
##########################################

# Dont forget disable Transparent Huge Pages (https://docs.mongodb.com/v3.6/tutorial/transparent-huge-pages/)
## THP_PATH=$(find /sys/kernel/ -name "transparent_hugepage")
## echo 'never' > $THP_PATH/enabled
## echo 'never' > $THP_PATH/defrag 

MONGO_CONTAINER="mongo.slave.service" # Nombre del contenedor
MONGO_PORT="27017" # Puerto por el que correrar Mongo
MONGO_REPLICATION_NAME="rsamxga" # Nombre del cluster
MONGO_EXTERNAL_PORT="27017" # Puerto externo por el que se expondra Mongo 
MONGO_EXTERNAL_IP="10.23.142.133" # Ip del servidor, debe ser accesible por los otros nodos

mkdir -p /var/containers/$MONGO_CONTAINER/{etc/mongo/,var/lib/mongodb/data,opt/mongodb/}

cat<<-EOF > /var/containers/$MONGO_CONTAINER/etc/mongo/mongod.conf
# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb/data
  journal:
    enabled: true

# where to write logging data.
#systemLog:
 # destination: file
 # logAppend: true
 # path: /var/lib/mongod.log

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
sBr6+yU9Y38t4ijpKm2cAGD/s6zK8nqVemq89wLe++wRagJhB8VfOWawq07BakAW
g3XV1KDlSG4Pg7H5lnAWsvC/y/e7duM2yhSdoTjQmtkCAPQgCCE7ol4E2+sE5T8R
qCp5tG5AZZ6HzyX4fKszaqpXJFo9R3/+EkmN1gYabScXwfrRh/WSD1ZMFJKrKP1w
YUP1KtZkRtRoHaNU1lEbfWgxxBQaHwijNoc9d1aaE2FH9+5TiND78C8leUzLafvR
uczNruFBynwhfDKOG82/kM5cl2Z/dGqFB398E3L8tymhPh1HfTECaiu8AT1BKaCF
3ueM5Z6FXa4REfpN2VYrIW4BXzr0LFqrUlDRllK95BYbqFHcWvs+BwTxg5B/oh8+
Mo9ycoTnv4Z+kejqFBCNwELCPBq8d1P6c9UhybqEQcWUtAc+GaJ9x4zOPF/Zwo6g
JGXuffjOLVS+DURoDbnTtgGkiajD5qHi/J9tkvEfpN9iQbfcNH7r0wUrJLvi0A26
UXiIx06gRmKBejnpO/VmBF7yPeFtIPmpNbsCgTK70UnrOV7+Fdz/rc+Z8tfdrpnz
z+t0FFeMyu6OupPB7pi4/oUl6WhZp95MtiHZb+vvkD0w/ewBijjlefm17HsfDstI
w8Ll74FyiNR1Lk4003AWtb75qwaVJDhSkCn4mvNgsad2B28Mv/7R4DzxVzhLhL3h
EU9HQoA09wddBewxD2xPGRcm3AqCckQWO6Nmkrqr1sAllTtkcnnhjOwysdufYYoA
WFOXE3AilN2UdWApv/w57Up6N0xeSN1w6AndEj54I85S/vuqoy9kfxOPoGs9/9tl
Ygcrs5edaIPfsD2yK7pViY5z/i+tG0UaU190te82xXMYXt4q8GDuOoN1lDY3AsQ5
5EXZQgGP2ReamTcOoEU1BUpoknoqktQFKDrNBn9r/ZBp8RQ2LpVLxcJulWCsXnmm
5GGEFOpb1oPBrzvDQh452aCqsoydY+/ZVBNTswFASA7sph/k
EOF
chmod 400 /var/containers/$MONGO_CONTAINER/opt/mongodb/mongo-keyfile

chown 184:184 -R /var/containers/$MONGO_CONTAINER

## Deploy Mongo container (master)
docker run -itd --name $MONGO_CONTAINER --restart=always \
    -p $MONGO_EXTERNAL_PORT:$MONGO_PORT \
    -v /var/containers/$MONGO_CONTAINER/var/lib/mongodb/data:/var/lib/mongodb/data:z \
    -v /var/containers/$MONGO_CONTAINER/opt/mongodb/:/opt/mongodb/:z \
    -v /var/containers/$MONGO_CONTAINER/etc/mongo:/etc/mongo:z \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -e "TZ=America/Mexico_City" \
    registry.redhat.io/rhscl/mongodb-36-rhel7 mongod --config /etc/mongo/mongod.conf

sleep 10
echo "[CS $(date)] Slave Node started."
echo "[CS $(date)] You should run this command on your Master Node to include this node on your cluster."
echo "rs.add(\"$MONGO_EXTERNAL_IP:$MONGO_EXTERNAL_PORT\")"