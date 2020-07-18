# Creación de Imagen PHP con extensión IBM DB2 2.0.8

Construcción y despliegue de nginx/php con IBM DB2 client.

## Prerequisitos

* Virtual CentOS 7 / Rhel
* Docker 1.13.X
* Git
* Imagen dockeregistry.amovildigitalops.com/rhel7-atomic

## Desarrollo

Clonar el repositorio con los archivos necesarios para la construcción de la imagen.

```bash
git clone http://infracode.amxdigital.net/kevin.gomez/php-ibm_db2-2.0.8.git /opt
```

Descargar el instalador del cliente db2 de IBM de la página de ibm:

https://www-945.ibm.com/support/fixcentral/swg/reorderFixes?parent=ibm%7EInformation%2BManagement&product=ibm/Information+Management/DB2&release=All&platform=Linux+64-bit,x86_64&function=fixId&fixids=DB2-linuxx64-universal_fixpack-11.1.4.4-FP004a&includeRequisites=1&includeSupersedes=0&downloadMethod=http&login=true

Mover al directorio clonado:

```bash
mv v11.1.4fp4a_linuxx64_universal_fixpack.tar.gz /opt/php-ibm_db2-2.0.8/docker/
```
A continuación llevamos a cabo la construcción de la imagen.

```bash
docker build -t atomic-rhel7-nginx-php-fpm72-ibm /opt/php-ibm_db2-2.0.8/docker/
```

Para llevar a cabo el despliegue del contenedor con dicha imagen hacemos uso del siguiente *Runit*

**NOTA: La variable instancia debe coincidir con la variable instuser en el container de la DB2**

```bash
CONTAINER=php72-rc1
instancia=db2amx

mkdir -p    /var/containers/${CONTAINER}/{var/log/php-fpm/,etc/opt/rh/rh-php72/,var/opt/rh/rh-php72/lib/php/session/} \
            /var/containers/shared/var/www/sites/ \
            /var/${CONTAINER}/tmp/ \
            /var/cache/containers/${CONTAINER}/

chown 48 /var/containers/${CONTAINER}/{var/log/php-fpm/,etc/opt/rh/rh-php72/,var/opt/rh/rh-php72/lib/php/session/} /var/${CONTAINER}/tmp/ /var/cache/containers/${CONTAINER}/

# Run container
docker run -td --name=${CONTAINER} --privileged=false \
                    --volume=/var/${CONTAINER}/tmp/:/tmp/:z \
                    --volume=/var/cache/containers/${CONTAINER}/:/var/cache/:z \
                    --volume=/etc/localtime:/etc/localtime:ro \
                    --volume=/usr/share/zoneinfo:/usr/share/zoneinfo:ro \
                    --volume=/var/containers/${CONTAINER}/var/log/php-fpm/:/var/log/php-fpm/:z \
                    --volume=/var/containers/shared/var/www/sites/:/var/www/sites/:ro,z \
                    --volume=/var/containers/${CONTAINER}/var/opt/rh/rh-php72/lib/php/session/:/var/opt/rh/rh-php72/lib/php/session/:z \
                    --hostname=${hostname}-${CONTAINER} \
                    --dns 172.27.140.132 \
                    -e "SESSION_HANDLER=redis" \
                    -e "SESSION_SAVE_PATH=tcp://redis-storage.dev.claroshop.com:6379?auth=@st0rAg3K3Y" \
                    -e "instance_name=$instancia" \
                    -p 9223:9000 \
                    atomic-rhel7-nginx-php-fpm72-ibm
```