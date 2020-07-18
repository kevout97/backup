# Monitoreo de un volumen privado usando Pyinotify

## Prerequisitos

* Virtual Rhel7/CentOS7
* Docker 1.13.X
* Imagen docker dockeregistry.amovildigitalops.com/rhel7-atomic
* Git

## Desarrollo

Clonamos el repositorio con los archivos necesarios para crear la imagen

```bash
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/bloqueo-de-usuario-root-con-selinux.git /opt/monitoreo-volumen
```

Construimos la imagen con el siguiente comando

```bash
docker build -t dockeregistry.amovildigitalops.com/atomic-rhel7-monitoring-volumen /opt/monitoreo-volumen/docker
```

Realizamos el despliegue del contenedor que monitoreará el volúmen con el siguiente runit

```bash
docker run -itd --privileged --name monitoring \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/private1:/private1:z \
    -v /var/containers/private2:/private2:z \
    -e "TZ=America/Mexico_City" \
    -e "MONITORING_RSYSLOG_HOST=10.23.143.8" \
    -e "MONITORING_RSYSLOG_PORT=515" \
    -e "MONITORING_RSYSLOG_PROTOCOL=UDP" \
    -e "MONITORING_DIRECTORIES=/private1;/private2" \
    dockeregistry.amovildigitalops.com/atomic-rhel7-monitoring-volumen
```

Donde:
* **MONITORING_RSYSLOG_HOST**: Host o Ip del servidor Rsyslog
* **MONITORING_RSYSLOG_PORT**: Puerto Rsyslog
* **MONITORING_RSYSLOG_PROTOCOL**: Protocolo de comunicación con Rsyslog (TCP o UDP)
* **MONITORING_DIRECTORIES**: Directorios a monitorear

**NOTA**: Los volúmenes a monitorear deben ser montados en dicho contenedor. Si se desea monitorear más de un directorio, en la bandera *MONITORING_DIRECTORIES* se pueden colocar en forma de lista, separadas por un ";".

E.g. -e "MONITORING_DIRECTORIES=/directorio1;/directorio2;/directorio3..."