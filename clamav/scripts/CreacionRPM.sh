#!/bin/bash

########################################################
#                                                      #
# Creación de rpm ClamAV.                              #
#                                                      #
########################################################

# Despliegue de contenedor
docker run -itd --name clamav \
    --hostname clamav \
    -v /var/containers/clamav/root:/root:z \
    centos

# Entramos al contenedor
docker exec -it clamav bash

# Actualizacion de paquetes
yum update -y

# Instalación de herramienta para creacion de RPM
yum install rpm-build rpmdevtools -y

# Instalacion de dependencias para compilado de ClamvAV
yum groupinstall "Development Tools" -y
yum install openssl openssl-devel libcurl-devel zlib zlib-devel libpng-devel libxml2-devel json-c-devel bzip2-devel pcre2-devel ncurses-devel valgrind check wget -y

# Generamos la estructura de directorios para crear el RPM
rpmdev-setuptree

# Solucionamos un error
echo "%_unpackaged_files_terminate_build      0" >> ~/.rpmmacros
echo "%_binaries_in_noarch_packages_terminate_build   0" >> ~/.rpmmacros

# Nos ubicamos en el directorio home del usuario
cd

# Descargamos el tar.gz de ClamAV
wget https://www.clamav.net/downloads/production/clamav-0.101.2.tar.gz

# Movemos los archivos a los directorios correspondientes
mv clamav-0.101.2.tar.gz ~/rpmbuild/SOURCES/
mv clamav.spec ~/rpmbuild/SPECS/

# Generamos los rpms
rpmbuild -ba ~/rpmbuild/SPECS/clamav.spec

# Cuando finalice la ejecución del comando, los RPMS se habran creado en el directorio ~/rpmbuild/RPMS
cd ~/rpmbuild/RPMS