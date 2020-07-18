#!/bin/bash

# Elimiar Warning de Apache 
echo 'ServerName localhost' >> /etc/httpd/conf/httpd.conf
# Copia de archivo de configuración
cp /etc/linotp2/linotp.ini.example /etc/linotp2/linotp.ini
cp /etc/httpd/conf.d/ssl_linotp.conf.template /etc/httpd/conf.d/linotp.conf
# Reasignacion de nombre 
mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.template
# Creacion de Supervisor
echo 'W3N1cGVydmlzb3JkXQpub2RhZW1vbj10cnVlCgpbcHJvZ3JhbTpodHRwZF0KY29tbWFuZD0vdXNyL3NiaW4vaHR0cGQgLUQgRk9SRUdST1VORAo=' | base64 -w0 -d > /etc/supervisord.d/supervisord.conf

