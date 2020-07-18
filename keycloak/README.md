# Keycloack 9.0.3

## Prerequisitos

* Virtual Rhel/CentOS 7
* Docker 1.13.X
* Mysql >= 5.7
* Git
* Imagen Docker dockeregistry.amovildigitalops.com/atomic-rhel7-java-8

## Desarrollo

Clonamos el repositorio con los archivos necesarios para la construcción de la imagen:

```bash
git clone http://infracode.amxdigital.net/desarrollo-tecnologico/keycloak-8.git /opt/atomic-rhel7-keycloak-9
```

Construimos la imagen con el siguiente comando:

```bash
cd /opt/atomic-rhel7-keycloak-9/docker
./build_this.sh
```

Para llevar a cabo el despliegue de de Keycloak primero es necesario crear la base de datos en la instancia Mysql.

Para este ejemplo la base de datos tendrá el nombre de **keycloak**.

*Dentro de Mysql*
```bash
mysql> CREATE DATABASE keycloak;
```
**NOTA: En la alta disponibilidad de Keycloak todas la instancias apuntan a la misma base de datos, por lo es preciso que dicha base datos pueda ser accesible por cada uno de los Keycloak**


A continuación ejecutamos el siguiente comando para levantar la instancia de Keycloak:

```bash
KEYCLOAK_CONTAINER="keycloak"
KEYCLOAK_VERSION="9.0.3"

mkdir -p /var/containers/$KEYCLOAK_CONTAINER/opt/keycloak-${KEYCLOAK_VERSION}/standalone/{data,log}
chown 500:500 -R /var/containers/$KEYCLOAK_CONTAINER/opt/keycloak-${KEYCLOAK_VERSION}

# Despliegue de Keycloak
docker run -itd --name $KEYCLOAK_CONTAINER --hostname $KEYCLOAK_CONTAINER.service \
    --restart unless-stopped \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/${KEYCLOAK_CONTAINER}/opt/keycloak-${KEYCLOAK_VERSION}/standalone/data:/opt/keycloak-${KEYCLOAK_VERSION}/standalone/data:z \
    -v /var/containers/${KEYCLOAK_CONTAINER}/opt/keycloak-${KEYCLOAK_VERSION}/standalone/log:/opt/keycloak-${KEYCLOAK_VERSION}/standalone/log:z \
    -e TZ=America/Mexico_City \
    -e "KEYCLOAK_AJP_PORT=8009" \
    -e "KEYCLOAK_HTTP_PORT=8080" \
    -e "KEYCLOAK_HTTPS_PORT=8443" \
    -e "KEYCLOAK_BIN_ADDRESS_MANAGEMENT=0.0.0.0" \
    -e "KEYCLOAK_BIN_ADDRESS=0.0.0.0" \
    -e "KEYCLOAK_MANAGEMENT_HTTP_PORT=9990" \
    -e "KEYCLOAK_MANAGEMENT_HTTPS_PORT=9993" \
    -e "KEYCLOAK_MYSQL_HOST=mysql57" \
    -e "KEYCLOAK_MYSQL_PORT=3306" \
    -e "KEYCLOAK_MYSQL_DATABASE=keycloak" \
    -e "KEYCLOAK_MYSQL_USER=root" \
    -e "KEYCLOAK_MYSQL_PASSWORD=abcd1234" \
    -e "KEYCLOAK_ADMIN_USER=admin" \
    -e "KEYCLOAK_ADMIN_PASSWORD=abcd1234" \
    -e "KEYCLOAK_JGROUPS_DISCOVERY_EXTERNAL_IP=10.23.143.8" \
    -e "KEYCLOAK_JGROUPS_TCP_PORT=7600" \
    -p 8080:8080 \
    -p 9990:9990 \
    -p 7600:7600 \
    --add-host mysql57:172.17.0.10 \
    dockeregistry.amovildigitalops.com/atomic-rhel7-keycloak-9
```

Donde:

* **KEYCLOAK_MYSQL_HOST**: Host o Ip donde se encuentra la base de datos (default:localhost)
* **KEYCLOAK_MYSQL_PORT**: Puerto por donde se expone la base de datos (default:3306)
* **KEYCLOAK_MYSQL_USER**: Usuario para la conexion a la base de datos (default:keycloak)
* **KEYCLOAK_MYSQL_PASSWORD**: Password para la conexión con la base de datos (default:keycloak)
* **KEYCLOAK_MYSQL_DATABASE**: Nombre de la base de datos previamente creada (default:keycloak)
* **KEYCLOAK_ADMIN_USER**: Primer usuario de Keycloak
* **KEYCLOAK_ADMIN_PASSWORD**: Password del primer usuario de Keycloak
* **KEYCLOAK_JGROUPS_DISCOVERY_EXTERNAL_IP**: Ip del servidor donde ha sido desplegado keycloak.
* **KEYCLOAK_JGROUPS_TCP_PORT**: Puerto por donde la instancia Keycloak se comunicara con las otras instancias Keycloak (default:7600), este puerto debe coincidir con el puerto del host

## Issues

### The server time zone value 'CDT'

Durante el despliegue se presento el siguiente problema

```bash
java.sql.SQLException: The server time zone value 'CDT' is unrecognized or represents more than one time zone. You must configure either the server or JDBC driver (via the serverTimezone configuration property) to use a more specifc time zone value if you want to utilize time zone support.
```

Esto se presenta porque la configuración de zona del systema en Mysql tiene el valor de CDT, dicho valor presenta una ambigüedad, pues bien puede referir a alguno de estos valores

```bash
CDT - Central Daylight Time, North America, UTC -5
CDT - Cuba Daylight Time, Caribbean, UTC -4
CDT - Chatham Daylight Time
```

Para solucionar dicho problema basta con cambiar el valor que la variable  `system_time_zone` de Mysql adopta, configurando la variable de entorno **TZ** (antes de llevar el despliegue del contenedor) con un valor distinto.

E.g.
```bash
docker run -itd --name mysql-keycloak \
    ...
    -e TZ=UTC \
    ...
```