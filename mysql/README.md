# Mysql 8.0.18

Creación de imagen y despliegue de Mysql 8.0.18

## Prerequisitos

* Virtual CentOS7 / Rhel
* Docker 1.13.X
* Imagen dockeregistry.amovildigitalops.com/rhel7-atomic

## Desarrollo

Clonamos el repositorio que contiene los archivos necesarios para la creación de la imagen.

```bash
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/mysql-8.0.17 /opt/mysql-8.0.17
```

Realizamos la construcción de la imagen con el siguiente comando

```bash
docker build -t dockeregistry.amovildigitalops.com/rhel7-atomic-mysql8.0 /opt/mysql-8.0.17/docker
```

Para hacer el despliegue del contenedor con la imagen creado, utilizamos el siguiente runit

```bash
name=mysql8

mkdir -p  /var/containers/$name/UD01/mysql/data/
mkdir -p  /var/containers/$name/var/log/mysql/ERROR/
mkdir -p  /var/backups/mysqldailybackup
mkdir -p  /var/containers/$name/var/log/mysql/binlogs
mkdir -p  /var/containers/$name/etc/mysql/
mkdir -p  /var/containers/$name/var/backups/ejecucionesscript/
mkdir -p  /var/containers/$name/var/tmp/mysql/


docker run -td \
    -v /var/backups/mysqldailybackup/:/var/backups/mysqldailybackup/:z \
    -v /var/containers/$name/var/log/mysql/binlogs/:/var/log/mysql/binlogs/:Z \
    -v /var/containers/$name/var/log/mysql/ERROR/:/var/log/mysql/ERROR/:Z \
    -v /var/containers/$name/UD01/mysql/data/:/UD01/mysql/data/:Z \
    -v /var/containers/$name/etc/mysql/:/etc/mysql/:Z \
    -v /var/containers/$name/var/backups/ejecucionesscript/:/var/backups/ejecucionesscript/:Z \
    -v /var/containers/$name/var/tmp/mysql/:/var/tmp/mysql/:Z \
    -v /etc/localtime:/etc/localtime:ro \
    --hostname=$name.service \
    --ulimit nofile=40240:40240 \
    --ulimit nproc=35000:40960 \
    -e 'mysql_root_password=abcd1234' \
    -e 'LANG=en_US.UTF-8' \
    -e 'PATH=/usr/local/mysql/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
    --name=$name \
    --restart unless-stopped \
    dockeregistry.amovildigitalops.com/rhel7-atomic-mysql8.0
```