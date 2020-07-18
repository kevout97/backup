# OpenDKIM

Construcción y despliegue de OpenDKIM para firmado de correos electrónicos. 

## Prerequisitos

* Virtual CentOS 7 / Rhel
* Docker 1.13.X
* Git
* Imagen dockeregistry.amovildigitalops.com/rhel7-atomic

## Desarrollo

### Construcción de la imagen 

Clonar el repositorio.
```sh
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/opendkim.git /opt/opendkim
```

Construir la imagen.
```sh
docker build -t dockeregistry.amovildigitalops.com/atomic-rhel7-opendkim /opt/opendkim/docker
```

### Levantar contenedor

El contenedor se levanta con el siguiente runit:
```sh
#!/bin/

######################################################
#                                                    #
# Runit Opendkim 2.11                                #
#                                                    #
######################################################

OPENDKIM_CONTAINER=opendkim
OPENDKIM_DOMAIN=dkim.amx.gadt.amxdigital.net # Dominio al que se añadira Dkim

docker run -itd --name $OPENDKIM_CONTAINER \
    -v /etc/localtime:/etc/localtime:ro \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -e "TZ=America/Mexico_City" \
    -e "OPENDKIM_DOMAIN=$OPENDKIM_DOMAIN" \
    -p 8891:8891 \
    dockeregistry.amovildigitalops.com/atomic-rhel7-opendkim
```

Donde: 
+ OPENDKIM_DOMAIN = Al dominio asociado con el servidor de correo.
