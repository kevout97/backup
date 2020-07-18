# Tomcat-9.0.27

## Prerequisitos

* Virtual Rhel7/CentOS
* Docker 1.13.X
* Imagen dockeregistry.amovildigitalops.com/atomic-rhel7-java-8

## Creación de imagen Tomcat 9.0.27

Clonar repositorio.

```sh
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/tomcat-9.0.27.git -b 9.0.27 /opt/tomcat
```

Construir imagen a partir del Dockerfile que se clonó en el repositorio.
```sh
docker build -t dockeregistry.amovildigitalops.com/rhel7-atomic-tomcat:9.0.27 /opt/tomcat/docker
```
Realizar el despliegue del contenedor con  el uso del siguiente runit:
```sh
#!/bin/bash
#######################################################################
#                        RUN TOMCAT CONTAINER                          #
#######################################################################

# Create base directories
TOMCAT_VERSION=9.0.27
TOMCAT_CONTAINER=tomcat

mkdir -p /var/containers/tomcat/usr/local/apache-tomcat-$TOMCAT_VERSION/{logs,webapps}
chown 9027:0 -R /var/containers/tomcat/usr/local/apache-tomcat-$TOMCAT_VERSION/{logs,webapps}

docker rm -f $TOMCAT_CONTAINER
docker run -td --name=$TOMCAT_CONTAINER 
    -p 6565:8080 \
    --privileged=false \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /var/containers/shared/var/www/sites/:/var/www/sites/:z \
    -v /var/containers/tomcat/usr/local/apache-tomcat-$TOMCAT_VERSION/logs/:/usr/local/apache-tomcat-$TOMCAT_VERSION/logs/:z \
    -v /var/containers/tomcat/usr/local/apache-tomcat-$TOMCAT_VERSION/webapps:/usr/local/apache-tomcat-$TOMCAT_VERSION/webapps:z \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TOMCAT_USER_GUI=tomcat" \
    -e "TOMCAT_PASSWORD_GUI=abcd1234" \
    -e "MAX_FILE_SIZE=209715200" \
    -e "CONNECTION_TIMEOUT=-1" \
    --hostname=$TOMCAT_CONTAINER.service \
    dockeregistry.amovildigitalops.com/rhel7-atomic-tomcat:9.0.27
```

**NOTA:** Las variables que se le pasan al contenedor son:

* TOMCAT_USR_GUI = Usuario para administrador de tomcat.
* TOMCAT_PASSWORD_GUI = Password para usuario administrador de tomcat.
* MAX_FILE_SIZE = Tamaño máximo para subir archivos war.
* CONNECTION_TIMEOUT = Timeout para la conexión de subida de archivos war (Mientras mayor sea el archivo, mayor debe ser el *Timeout*). 

**'-1' Desactiva el *Timeout***

*209715200 == 200MB*

*104857600 == 100MB*