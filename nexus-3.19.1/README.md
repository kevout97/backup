# Nexus 3.19.1

Construcción y despliegue de Nexus 3.19.1 para una posterior actualización a dicha versión.

## Prerequisitos

* Virtual CentOS 7 / Rhel
* Docker 1.13.X
* Git
* Imagen dockeregistry.amovildigitalops.com/atomic-rhel7-java-8

## Desarrollo

Generar el directorio donde almacenaremos todos los archivos utilizados durante la creación de la imagen.

```bash
mkdir -p /opt/nexus-3.19.1/
```

Clonar repositorio Nexus
```sh
git clone http://infracode.amxdigital.net/desarrollo-tecnologico/nexus-3.18.1.git /opt/nexus-3.19.1/
```
### Construcción de Imagen Nexus:3.19.1

```bash
docker build -t dockeregistry.amovildigitalops.com/rhel7-atomic-nexus3.19 /opt/nexus-3.19.1/docker/
```

Para llevar a cabo el despliegue del contenedor con dicha imagen hacemos uso del siguiente *Runit*

```bash
docker run -td --hostname=nexus.service --privileged=true --name nexus --cap-add=IPC_OWNER \
            -p 8081:8081 \
            -p 5000:5000 \
            --health-cmd='/sbin/docker-health-check.sh' \
            --health-interval=10s \
            --restart unless-stopped \
            -v /etc/localtime:/etc/localtime:ro \
            -v /var/containers/nexus/opt/sonatype:/opt/sonatype/:z \
            -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
            -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
            -e TZ=America/Mexico_City \
            -e "NEXUS_XMS=512M" \
            -e "NEXUS_XMX=2g" \
            -e "NEXUS_MAX_DIRECTORY_MEMORY_SIZE=2g" \
            -e "NEXUS_PREFER_IPV4=true" \
            -e "NEXUS_HTTP_PORT=8081" \
            -d dockeregistry.amovildigitalops.com/rhel7-atomic-nexus3.19
```

Verificar que Nexus se haya desplegado de manera correcta.

```bash
curl <ipcontainer>:8081
```

### Actualización de Nexus 3.06 a Nexus 3.19.1

Para llevar a cabo la actualización de Nexus, primero realizamos un backup del contenido actual de Nexus.

```bash
tar -cvzf /opt/nexus-3.06.bck.tar.gz /var/containers/nexus
```

A continuación eliminamos el directorio que contiene toda la instalación del Nexus actual. 
**Nota: El directorio nexus guarda solamente la información correspondiente a la herramienta, todo lo que se genera con el uso de la misma va al directorio sonatype-work que se mantendrá igual para que se monte con el nuevo contenedor.**

```bash
rm -rf /var/containers/nexus/opt/sonatype/app/nexus
```

Eliminar el contenedor actual de Nexus

```bash
docker rm -f nexus
```

Proceder a desplegar la nueva versión de Nexus, a continuación el archivo runit.
*NOTA: La imagen utilizada en el siguiente despliegue es la misma que se construyó en pasos anteriores*

```bash
docker run -td --hostname=nexus.service --privileged=true --name nexus --cap-add=IPC_OWNER \
            -p 8081:8081 \
            -p 5000:5000 \
            --health-cmd='/sbin/docker-health-check.sh' \
            --health-interval=10s \
            --restart unless-stopped \
            -v /etc/localtime:/etc/localtime:ro \
            -v /var/containers/nexus/opt/sonatype:/opt/sonatype/:z \
            -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
            -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
            -e TZ=America/Mexico_City \
            -e "NEXUS_XMS=512M" \
            -e "NEXUS_XMX=2g" \
            -e "NEXUS_MAX_DIRECTORY_MEMORY_SIZE=2g" \
            -e "NEXUS_PREFER_IPV4=true" \
            -e "NEXUS_HTTP_PORT=8081" \
            -d dockeregistry.amovildigitalops.com/rhel7-atomic-nexus3.19
```