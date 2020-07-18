# SFTP-Server

## Prerequisitos

* Virtual Rhel7/CentOS
* Docker 1.13.X
* Imagen dockeregistry.amovildigitalops.com/rhel7-atomic

## Creación de la imagen

Clonar repositorio.
```sh
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/sftp-server /opt/
```

Construir la imagen con base en el *Dockerfile* y *entrypoint* dados.
```sh
docker build -t rhel7-atomic-sftp /opt/sftp-server/docker
```

Realizar el despliegue del contenedor con  el uso del siguiente runit:
```sh
#!/bin/bash

###########################################################
#                                                         #
#                   RUNIT SFTP SERVICE                    #
#                                                         #
###########################################################
rm -rf /var/containers/sftp

docker rm -f sftp

mkdir -p /var/containers/sftp/var/share

docker run -d --name sftp -p 2222:22 \
    -v /var/containers/sftp/var/share:/var/share:z \
    -e "SFTP_DIRECTORY=/var/share" \
    -e "SFTP_USER=<usuario>" \
    -e "SFTP_USER_KEY=<llave-publica>" \
    rhel7-atomic-sftp
```

**NOTA:** De no especificarse la variable SFTP_DIRECTORY por defecto se utiliza el directorio */var/share*

* SFTP_DIRECTORY = Directorio que se usará para el almacenamiento de archivos (el usuario solo podrá subir archivos en el directorio que lleva su nombre).
* SFTP_USER = Usuario que accederá al servidor SFTP.
* SFTP_USER_KEY = Llave pública del usuario que accederá al servidor SFTP.