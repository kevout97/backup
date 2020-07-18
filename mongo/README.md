# Mongodb 4.2.2

Creación de imagen y despliegue de contenedor de Mongodb 4.2.2

## Prerequisitos

* Docker 1.13.X
* Virtual CentOS / Rhel
* Imagen dockeregistry.amovildigitalops.com/rhel7-atomic

## Desarrollo

Clonar repositorio de Mongo 
```sh
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/mongo-4.0.2.git /opt/mongodb
```

Creamos la imagen de mongo

```bash
docker build -t rhel7-atomic-mongodb:4.2.2 /opt/mongodb/docker
```

Para realizar el despliegue del contenedor, hacemos uso de los siguientes comandos:

```bash
mkdir -p /var/containers/mongodb/{data/db,var/{log/mongodb,lib/mongo}}

docker run -td --name mongodb42 -p 27017:27017 \
            -v /var/containers/mongodb/data/db:/data/db:z \
            -v /var/containers/mongodb/var/log/mongodb:/var/log/mongodb:z \
            -v /var/containers/mongodb/var/lib/mongo:/var/lib/mongo:z \
            -v /etc/localtime:/etc/localtime:ro \
            --hostname=mongodb.service \
            -e "mongo_root_password=Mongopasswordamxgadt1" \
            rhel7-atomic-mongodb:4.2.0
```