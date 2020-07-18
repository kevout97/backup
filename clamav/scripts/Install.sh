#!/bin/bash

########################################################
#                                                      #
# Instalación de ClamAV desde codigo fuente.           #
#                                                      #
#                                                      #
########################################################

# Despliegue de contenedor
docker run -itd --name clamav \
    --hostname clamav \
    -v /var/containers/clamav/root:/root:z \
    centos

# Entramos al contenedor
docker exec -it clamav bash

# Instalacion de Dependencias
yum update -y
yum install rpm-build rpmdevtools -y
yum groupinstall "Development Tools" -y
yum install openssl openssl-devel libcurl-devel zlib zlib-devel libpng-devel libxml2-devel json-c-devel bzip2-devel pcre2-devel ncurses-devel valgrind check wget -y


# Nos ubicamos en /opt/clamav
cd /opt/clamav

# Descagamos los binarios
wget https://www.clamav.net/downloads/production/clamav-0.101.2.tar.gz

# Descomprimir el binario
tar -xzvf clamav-0.101.2.tar.gz

# Nos ubicamos dentro del directorio
cd /opt/clamav/clamav-0.101.2

# Configuracion de ClamAV
./configure --with-systemdsystemunitdir=no --sysconfdir=/etc

# Compilar ClamAV
make -j2

# Verificar configuracion
make check

# Instalacion de ClamAV
make install

# Archvios de configuracion
cp /etc/freshclam.conf.sample /etc/freshclam.conf

yum groupinstall "Development Tools" -y
yum install openssl openssl-devel libcurl-devel zlib-devel libpng-devel libxml2-devel json-c-devel bzip2-devel pcre2-devel ncurses-devel valgrind check libtool-ltdl-devel -y
curl -o clamav-0.101.2.tar.gz https://www.clamav.net/downloads/production/clamav-0.101.2.tar.gz
tar xzf clamav-0.101.2.tar.gz
cd clamav-0.101.2
./configure --with-systemdsystemunitdir=no
###### For RPM creation ###### ./configure --sysconfdir=/etc --enable-check
make -j2
make check #optional
make install
cp /etc/freshclam.conf.sample /etc/freshclam.conf
cp /etc/clamd.conf.sample /etc/clamd.conf
mkdir /usr/local/share/clamav
groupadd clamav
useradd -g clamav -s /bin/false -c "Clam Antivirus" clamav
chown -R clamav:clamav /usr/local/share/clamav
## Comandos post instalación RPM ##
freshclam -l /var/log/freshclam.log #Actualiza la BD de virus
clamscan -r --remove --bell -l escan.log /home #Primer escaneo a /home