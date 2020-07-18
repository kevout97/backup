# Cluster Mongo

## Prerequisitos

* Imagen docker registry.redhat.io/rhscl/mongodb-36-rhel7

## Desarrollo

### Nodo Master

Para el despliegue del nodo Master de Mongo nos apoyamos del script [mongo.master.runit.sh](mongo.master.runit.sh).

> Importante modificar las siguientes variables.

* **MONGO_CONTAINER**: *Nombre del contenedor*
* **MONGO_PORT**: *Puerto por el que correrar Mongo*
* **MONGO_USER**: *Usuario administrador*
* **MONGO_PASSWORD**: *Password del usario administrador*
* **MONGO_REPLICATION_NAME**: *Nombre del cluster de Mongo*
* **MONGO_EXTERNAL_PORT**: *Puerto externo por el que se expondra Mongo*
* **MONGO_EXTERNAL_IP**: *Ip del servidor, debe ser accesible por los otros nodos*
  
Al finalizar la ejecución del script se mostrará la key que debe ser copiada posteriormente en los nodos Slave.

## Nodo Slave

Una vez que el nodo Master ha sido desplegado podemos levantar los nodos Slave apoyados del script [mongo.slave.runit.sh](mongo.slave.runit.sh).

> Importante modificar las siguientes variables.

* **MONGO_CONTAINER**: *Nombre del contenedor*
* **MONGO_PORT**: *Puerto por el que correrar Mongo*
* **MONGO_REPLICATION_NAME**: *Nombre del cluster de Mongo*
* **MONGO_EXTERNAL_PORT**: *Puerto externo por el que se expondra Mongo*
* **MONGO_EXTERNAL_IP**: *Ip del servidor, debe ser accesible por los otros nodos*

En esta sección del script, debera colocarse la key generada en el nodo Master de Mongo
```bash
## Configurung key to replication
### Key generada en el Nodo Master
cat<<-EOF > /var/containers/$MONGO_CONTAINER/opt/mongodb/mongo-keyfile
# Key generada en el nodo master
EOF
```

Al finalizar la ejecución del script es necesario agregar el nodo al cluster, para ello, dentro en el nodo Master ejecutamos los siguientes comandos

*Ingreamos a Mongo*
```bash
docker exec -it nombre_del_contenedor mongo admin -u usuario_administrador -p
# Ingresamos el password del usuario
```

*Agregamos el nodo Slave al cluster*
```bash
rs.add("ip_node_slave:port_node_slave")
```