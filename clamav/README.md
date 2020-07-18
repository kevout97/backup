# Instalación de ClamAv

## Prerequisitos

* Virtual Rhel7/CentOS 7
* docker 1.13.X

## Desarrollo

Clonamos el directorio para la construcción de ClamAv

```bash
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/clamav.git
```

Construimos la imagen con el siguiente comando:

```bash
docker build -t dockeregistry.amovildigitalops.com/centos7-clamav /opt/clamav/docker
```
Levantar el contenedor a partir de la imagen creada en el paso anterior.
```bash
docker run -ti --name clamav -v /var/containers/clamav/root/rpmbuild/RPMS:/root/rpmbuild/RPMS/:z dockeregistry.amovildigitalops.com/centos7-clamav
```
Una vez finalizada la ejecución del contenedor, los archivos RPM estarán situados en el directorio **/var/containers/clamav/root/rpmbuild/RPMS/noarch/**

Instalar una dependencia necesaria para la instalación y funcionamiento de clamav:
```bash
yum install -y pcre2-devel
```
Nos trasladamos al directorio donde se encuentran los cuatro archivos rpm generados por el contenedor.
```bash
cd /var/containers/clamav/root/rpmbuild/RPMS/noarch/
```
Instalar los rpm de ClamAV:
```bash
rpm -ivh *.rpm
```
Crear archivo log para actualización de la base de datos de virus:
```bash
touch /var/log/freshclam.log 
```
Cambiar propietario y permisos al archivo log para actualización de base de datos de virus:
```bash
chown clamav:clamav /var/log/freshclam.log
chmod 600 /var/log/freshclam.log
```

Crear instrucción para crontab de root que verifique actualización y verificación de la base de datos de virus diariamente a las 2 am:
```bash
echo "00 02 * * * /bin/freshclam --quiet -l /var/log/freshclam.log" >> /var/spool/cron/root
```
Descargar por primera vez la base de datos de virus:
```bash
freshclam --quiet -l /var/log/freshclam.log
```
Si SeLinux está habilitado en el servidor:
```bash
setsebool -P antivirus_can_scan_system 1
setsebool -P clamd_use_jit 1
```
Ejemplo de uso:

```bash
clamscan -r --remove --bell -l scan.log /home
```
En este ejemplo escaneamos el directorio **/home** de forma recursiva ‘**-r**’.
Indicamos que cada archivo infectado sea eliminado ‘**--remove**’, que suene un pitido al encontrarlo ‘**--bell**’ e indicamos un archivo de log donde guardará el resultado del escaneo ‘**-l**’.