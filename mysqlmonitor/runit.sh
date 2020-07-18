#!/bin/bash
### Despliegue server monitor #######

# NOTA: Antes de desplegar el Monitor, ya debe existir la base de datos donde almacenará toda la información

# MYSQL_INSTANCE_NAME=mysql57-monitor

# mkdir /var/containers/${MYSQL_INSTANCE_NAME}/{var/log/mysql,var/lib/mysql,var/backups/ejecucionesscript,etc/mysql,tmp} -p
# chmod 777 /var/containers/${MYSQL_INSTANCE_NAME}/tmp -R
# docker run -td  -v /var/containers/${MYSQL_INSTANCE_NAME}/var/log/mysql/:/var/log/mysql/:z \
#                 -v /var/containers/${MYSQL_INSTANCE_NAME}/var/lib/mysql/:/var/lib/mysql/:z \
#                 -v /var/containers/${MYSQL_INSTANCE_NAME}/etc/mysql/:/etc/mysql/:z \
#                 -v /var/containers/${MYSQL_INSTANCE_NAME}/var/backups/ejecucionesscript/:/var/backups/ejecucionesscript/:z \
#                 -v /var/containers/${MYSQL_INSTANCE_NAME}/tmp:/tmp/:z \
#                 --hostname=${MYSQL_INSTANCE_NAME}.service \
#                 --ulimit nofile=10240:10240 \
#                 --ulimit nproc=2000:2000 \
#                 -e TZ=America/Mexico_City \
#                 -v /etc/localtime:/etc/localtime:ro \
#                 -e 'mysql_root_password=abcd1234' \
#                 --name=${MYSQL_INSTANCE_NAME} \
#                 dockeregistry.amovildigitalops.com/rhel72mysql5717ee

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
    -p 18080:18080 \
    -p 18443:18443 \
    -p 13306:13306 \
    --add-host="mysql57monitor:172.17.0.16" \
    dockeregistry.amovildigitalops.com/rhel7-atomic-mysqlmonitor:8.0.18

# Consultar https://ip-servidor:18443

# Donde:
# * *MYSQLM_ADMIN_USER*: Es el usuario creado para la base de datos que almacenará la información del servicio de MysqlMonitor.
# * *MYSQLM_ADMIN_PASSWORD*: Password del usuario para la base de datos que almacenará la información del servicio MysqlMonitor.
# * *MYSQLM_SYSTEM_SIZE*: Tipo de instalación, los posibles valores son:
# 	* small (5 a 10 servidores MySQL monitoreados desde una computadora portátil o servidor de gama baja con no más de 4 GB de RAM). 
# 	* medium (hasta 100 servidores MySQL monitoreados desde un servidor mediano, pero compartido, con 4 a 8 GB de RAM.
# 	* large (más de 100 servidores MySQL monitoreados desde un servidor dedicado de alta gama, con más de 8 GB de RAM).
# * *MYSQLM_DB_HOST*: Host o Ip de la base de datos que almacenará la información del servicio MysqlMonitor. (Si la variable es declarada con los valores **127.0.0.1**, **localhost** o no es declarada, el tipo de despliegue sera *bundled* donde la base de datos y el servicio de Mysql Monitor viven en el mismo contenedor)
# * *MYSQLM_DB_PORT*: Puerto por donde escucha la base de datos que almacenará la información del servicio MysqlMonitor. (Si no se declara el valor por defecto es **1336**)
# * *MYSQLM_DB_NAME*: Nombre de la base de datos que almacenará la información del servicio MysqlMonitor. (Si no se declara el valor por defecto es **mem**)



### Despliegue agente #######

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
    -e "MYSQLM_AGENT_USER=agente" \
    -e "MYSQLM_AGENT_PASSWORD=abcd1234" \
    -e "MYSQLM_AGENT_MANAGER_HOST=mysqlm-server" \
    -e "MYSQLM_AGENT_MANAGER_PORT=18443" \
    --add-host="mysqlm-server:10.23.143.8" \
    dockeregistry.amovildigitalops.com/rhel7-atomic-mysqlmonitor:8.0.18

# Donde:
# * *MYSQLM_AGENT*: Bandera que indica que el despliegue a realizar es el de un agente (Valores posbiles: *true*).
# * *MYSQLM_AGENT_USER*: Usuario con el que el agente podrá conectarser a Mysql Monitor Server.
# * *MYSQLM_AGENT_PASSWORD*: Password con el que el agente podrá conectarser a Mysql Monitor Server.
# * *MYSQLM_AGENT_MANAGER_HOST*: Host o Ip del Mysql Monitor Server al que se conectará dicho agente.
# * *MYSQLM_AGENT_MANAGER_PORT*: Puerto del Mysql Monitor Server por el que se conectará dicho agente. (Regularmente la conexion es por el puerto: **18443**)