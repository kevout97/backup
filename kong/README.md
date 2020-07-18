# Kong 1.4.2

Creación y despliegue de imagen Kong 1.4.2

## Prerequisitos

* Virtual Rhel7/CentOS 7
* Docker 1.13.X
* Imagen docker dockeregistry.amovildigitalops.com/rhel7-atomic
* Imagen docker Cassandra
* Git

## Desarrollo

Clonamos el repositorio con los archivos necesarios para la construcción de la imagen

```bash
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/kong-1.4.2.git -b 1.4.2 /opt/kong
```

Para construir la imagen hacemos uso del siguiente comando

```bash
docker build -t dockeregistry.amovildigitalops.com/atomic-rhel7-kong:1.4.2 /opt/kong/docker
```

Para el despliegue de la imagen utilizamos el siguiente runit

```bash
KONG_CONTAINER=kong

docker run -itd --name $KONG_CONTAINER \
    --hostname=$KONG_CONTAINER.service \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    -e "KONG_CASSANDRA_KEYSPACE=kong" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    -e "KONG_CASSANDRA_USERNAME=admin" \
    -e "KONG_CASSANDRA_PASSWORD=abcd1234" \
    -p 8001:8001 \
    -p 8444:8444 \
    --add-host kong-database:10.23.143.7 \
    dockeregistry.amovildigitalops.com/atomic-rhel7-kong:1.4.2
```

Donde:
* **KONG_CASSANDRA_CONTACT_POINTS**: Ip o Host de la base de datos Cassandra
* **KONG_CASSANDRA_USERNAME**: Usuario que permitira la conexion con Cassandra
* **KONG_CASSANDRA_PASSWORD**: Password del usuario de Cassandra
* **KONG_CASSANDRA_KEYSPACE**: Nombre de la base de datos

**NOTA**: La imagen admite como variable de entorno todos los parámetros que pueden ser configuradas en el archivo [kong.conf](docker/kong.conf) solo hace falta colocarlas con el prefijo **KONG_** y en mayúsculas. Ej.
    * **proxy_listen** pasaria a ser **KONG_PROXY_LISTEN**

En el archivo [kong.conf](docker/kong.conf) de este repositorio se muestran los valores por defecto con los que se levanta el servicio.