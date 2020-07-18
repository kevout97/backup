# MysqlMonitor 8.0.18

Creación de imagen MysqlMonitor 8.0.18

## Prerequisitos

* Virtual CentOS7/Rhel7
* Docker 1.13.X
* Imagen docker dockeregistry.amovildigitalops.com/rhel7-atomic
* Git

## Desarrollo

Clonamos el repositorio el cual contendrá los archivos necesarios para la construcción de la imagen.

```bash
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/mysqlmonitor -b 8.0.18 /opt/mysqlmonitor
```

Creamos la imagen a partir del siguiente comando.

```bash
docker build -t dockeregistry.amovildigitalops.com/rhel7-atomic-mysqlmonitor:8.0.18 /opt/mysqlmonitor/docker/
```

### Mysql Monitor Server
Para crear un contenedor del tipo **Mysql Monitor Server** hacemos uso de los siguientes comandos.

Generamos los volúmenes que utilizará el contenedor, haciendolos propietarios del usuario con UID 2626.

**NOTA:** El UID 2626 no puede cambiarse por otro, de lo contrario el servicio no podrá levantarse.

*Creación de directorio*
```bash
mkdir -p /var/containers/mysqlmonitor-server/opt/mysql/enterprise
```

*Cambio de propietario*
```bash
chown -R 2626:root /var/containers/mysqlmonitor-server/opt/mysql/enterprise
```

Realizamos el despliegue del contenedor con el siguiente comando

```bash
NAME_MONITOR=mysqlmonitor-server
mkdir -p /var/containers/$NAME_MONITOR/opt/mysql/enterprise/
chown 2626:root -R /var/containers/$NAME_MONITOR/opt/mysql/enterprise

docker run -d --name $NAME_MONITOR \
    --hostname=$NAME_MONITOR.service \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /var/containers/$NAME_MONITOR/opt/mysql/enterprise/:/opt/mysql/enterprise/:z \
    -e TZ=America/Mexico_City \
    -e "MYSQLM_ADMIN_USER=root" \
    -e "MYSQLM_ADMIN_PASSWORD=abcd1234" \
    -e "MYSQLM_SYSTEM_SIZE=large" \
    -e "MYSQLM_DB_HOST=mysql57monitor" \
    -e "MYSQLM_DB_PORT=3306" \
    -e "MYSQLM_DB_NAME=mysqlmonitorv2" \
    -p 18081:18080 \
    -p 18444:18443 \
    -p 13307:13306 \
    --add-host="mysql57monitor:172.17.0.16" \
    dockeregistry.amovildigitalops.com/rhel7-atomic-mysqlmonitor:8.0.18
```

Donde:
* *MYSQLM_ADMIN_USER*: Es el usuario creado para la base de datos que almacenará la información del servicio de MysqlMonitor.
* *MYSQLM_ADMIN_PASSWORD*: Password del usuario para la base de datos que almacenará la información del servicio MysqlMonitor.
* *MYSQLM_SYSTEM_SIZE*: Tipo de instalación, los posibles valores son:
	* small (5 a 10 servidores MySQL monitoreados desde una computadora portátil o servidor de gama baja con no más de 4 GB de RAM). 
	* medium (hasta 100 servidores MySQL monitoreados desde un servidor mediano, pero compartido, con 4 a 8 GB de RAM.
	* large (más de 100 servidores MySQL monitoreados desde un servidor dedicado de alta gama, con más de 8 GB de RAM).
* *MYSQLM_DB_HOST*: Host o Ip de la base de datos que almacenará la información del servicio MysqlMonitor. (Si la variable es declarada con los valores **127.0.0.1**, **localhost** o no es declarada, el tipo de despliegue sera *bundled* donde la base de datos y el servicio de Mysql Monitor viven en el mismo contenedor)
* *MYSQLM_DB_PORT*: Puerto por donde escucha la base de datos que almacenará la información del servicio MysqlMonitor. (Si no se declara el valor por defecto es **1336**)
* *MYSQLM_DB_NAME*: Nombre de la base de datos que almacenará la información del servicio MysqlMonitor. (Si no se declara el valor por defecto es **mem**)

### Mysql Monitor Agent
Para crear un contenedor del tipo **Mysql Monitor Agent** hacemos uso de los siguientes comandos.

Generamos los volúmenes que utilizará el contenedor, haciendolos propietarios del usuario con UID 2626.

**NOTA:** El UID 2626 no puede cambiarse por otro, de lo contrario el servicio no podrá levantarse.

*Creación de directorio*
```bash
mkdir -p /var/containers/mysqlmonitor-agent/opt/mysql/enterprise
```

*Cambio de propietario*
```bash
chown -R 2626:root /var/containers/mysqlmonitor-agent/opt/mysql/enterprise
```

Realizamos el despliegue del contenedor con el siguiente comando

```bash
NAME_AGENT=mysqlmonitor-agent
mkdir -p /var/containers/$NAME_AGENT/opt/mysql/enterprise/
chown 2626:root -R /var/containers/$NAME_AGENT/opt/mysql/enterprise

docker run -d --name $NAME_AGENT \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    --hostname=$NAME_AGENT.service \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /var/containers/$NAME_AGENT/opt/mysql/enterprise/:/opt/mysql/enterprise/:z \
    -e TZ=America/Mexico_City \
    -e "MYSQLM_AGENT=true" \
    -e "MYSQLM_AGENT_USER=laura" \
    -e "MYSQLM_AGENT_PASSWORD=abcd1234" \
    -e "MYSQLM_AGENT_MANAGER_HOST=mysqlm-server" \
    -e "MYSQLM_AGENT_MANAGER_PORT=18444" \
    --add-host="mysqlm-server:10.23.143.8" \
    dockeregistry.amovildigitalops.com/rhel7-atomic-mysqlmonitor:8.0.18
```

Donde:
* *MYSQLM_AGENT*: Bandera que indica que el despliegue a realizar es el de un agente (Valores posbiles: *true*).
* *MYSQLM_AGENT_USER*: Usuario con el que el agente podrá conectarser a Mysql Monitor Server.
* *MYSQLM_AGENT_PASSWORD*: Password con el que el agente podrá conectarser a Mysql Monitor Server.
* *MYSQLM_AGENT_MANAGER_HOST*: Host o Ip del Mysql Monitor Server al que se conectará dicho agente.
* *MYSQLM_AGENT_MANAGER_PORT*: Puerto del Mysql Monitor Server por el que se conectará dicho agente. (Regularmente la conexion es por el puerto: **18443**)
