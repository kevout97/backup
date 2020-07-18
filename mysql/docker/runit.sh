#!/bin/bash

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