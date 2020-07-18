# Mobilefirst

Creación de imágenes Docker Mobilefirst Platform y Mobilefirst Analytics base Rhel7

## Prerequisitos

* Virtual Rhel7/CentOS
* Imagen dockeregistry.amovildigitalops.com/rhel7-atomic
* Contenedor DB2 con una base de datos ya creada para mobilefirst. (create database MFPDATA)
* Tener Java 8+ instalado

## Desarrollo

## Creación de imagen y contenedor para Mobilefirst Platform Server

Crear un directorio para la construcción de Mobilefirst.
```sh
mkdir -p /opt/MobileFirst
```

Descargar el zip de IBM para MobileFirst.

```sh
wget https://nexus.san.gadt.amxdigital.net/repository/cloud/amx/IBM_MOBILEFIRST_PLATFORM_FOUNDATI.zip -P /opt/MobileFirst
```
Desempaquetar el zip de Mobilefirst.
```sh
unzip /opt/MobileFirst/IBM_MOBILEFIRST_PLATFORM_FOUNDATI.zip -d /opt/MobileFirst/
```
Exportar JAVA_HOME
```sh
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
```
Configuración para la conexión con la base de datos. 

**Llenar según la BD**
```sh
cat << EOF > /opt/MobileFirst/mfpf-server/scripts/args/prepareserverdbs.properties
DB_TYPE="DB2"
DB2_HOST="172.17.0.6"
DB2_DATABASE="mfrhel"
DB2_PORT="50000"
DB2_USERNAME="db2amx"
DB2_PASSWORD="mipasswordmuysecreto"
ENABLE_PUSH="Y"
EOF
```
Donde:
* DB_TYPE= Gestor de base de datos. (DB2 o Bluemix)
* DB2_HOST= Host donde está la BD.
* DB2_DATABASE= Nombre de la base de datos.
* DB2_PORT= Puerto por donde se expone la BD.
* DB2_USERNAME= Usuario para la conexión a la base de datos.
* DB2_PASSWORD= Password para la conexión a la base de datos.
* ENABLE_PUSH= Habilitar push a base de datos. (Y o N)

Crear el schema de la base de datos.
```sh
/opt/MobileFirst/mfpf-server/scripts/prepareserverdbs.sh /opt/MobileFirst/mfpf-server/scripts/args/prepareserverdbs.properties
```

Construir imagen de Mobilefirst.
```sh
echo 'SERVER_IMAGE_TAG="dockeregistry.amovildigitalops.com/rhel7-atomic-mfpserver8"' > /opt/MobileFirst/mfpf-server/scripts/args/prepareserver.properties
```
Donde SERVER_IMAGE_TAG es el nombre de la imagen. 

Editar script de creación de imagen para omitir push.
```sh
sed -i '$d' /opt/MobileFirst/mfpf-server/scripts/prepareserver.sh && sed -i '$d' /opt/MobileFirst/mfpf-server/scripts/prepareserver.sh
```

```sh
/opt/MobileFirst/mfpf-server/scripts/prepareserver.sh /opt/MobileFirst/mfpf-server/scripts/args/prepareserver.properties
```
Levantar el contenedor.
```sh
docker run -td --hostname=mfp-server --privileged=true --name mobilefirst-farm \
    -p 9080:9080 -p 9443:9443 \
    -v /var/containers/mobilefirst/opt/ibm/wlp/usr/servers/:/opt/ibm/wlp/usr/servers/:z \
    -v /etc/localtime:/etc/localtime:ro \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    --health-cmd='/sbin/docker-health-check.sh' \
    --health-interval=10s \
    --restart unless-stopped \
    -e TZ=America/Mexico_City \
    -e "IP_ADDRESS=10.23.142.134" \
    -e "MFPF_SERVER_HTTPPORT=9080" \
    -e "MFPF_SERVER_HTTPSPORT=9443" \
    -e "MFPF_DB2_SERVER_NAME=172.17.0.6" \
    -e "MFPF_DB2_PORT=50000" \
    -e "MFPF_DB2_DATABASE_NAME=MFKEVS" \
    -e "MFPF_DB2_USERNAME=db2amx" \
    -e "MFPF_DB2_PASSWORD=mipasswordmuysecreto" \
    -e "MFPF_USER=amxga" \
    -e "MFPF_USER_PASSWORD=abcd1234" \
    -e "MFPF_ADMIN_USER=amxgaadmin" \
    -e "MFPF_ADMIN_USER_PASSWORD=abcd12345" \
    -e "ANALYTICS_ADMIN_USER=amxga" \
    -e "ANALYTICS_ADMIN_PASSWORD=abcd1234" \
    -e "ANALYTICS_URL=http://10.23.143.8:9082" \
    -e "MFPF_CLUSTER_MODE=Farm" \
    -e "MFPF_SERVER_ID=amxga-farm-ccmk" \
    dockeregistry.amovildigitalops.com/rhel7-atomic-mfpserverfarm
```

## Creación de imagen y contenedor para Mobilefirst Platform Analytics

Crear directorio para construcción de la imagen.
```sh
mkdir -p /opt/MFAnalytics
```
Crear el Dockerfile.
```sh
echo 'RlJPTSBkb2NrZXJlZ2lzdHJ5LmFtb3ZpbGRpZ2l0YWxvcHMuY29tL3JoZWw3LWF0b21pYwpMQUJFTCBtYWludGFpbmVyPSJLZXZpbiBHw7NtZXogJiBNYXVyaWNpbyBNZWzDqW5kZXogLyBBTVggR0EiCgpSVU4gY3VybCBodHRwczovL3JlcG9zLmFteGRpZ2l0YWwubmV0L3JoZWwtc2VydmVyLXJoc2NsLTctcnBtcy5yZXBvICAtbyAvZXRjL3l1bS5yZXBvcy5kL3JoZWwtc2VydmVyLXJoc2NsLTctcnBtcy5yZXBvICYmIGN1cmwgaHR0cHM6Ly9yZXBvcy5hbXhkaWdpdGFsLm5ldC9yaGVsLTctc2VydmVyLXJwbXMucmVwbyAtbyAvZXRjL3l1bS5yZXBvcy5kL3JoZWwtNy1zZXJ2ZXItcnBtcy5yZXBvCgpSVU4gbWljcm9kbmYgdXBkYXRlICYmIG1pY3JvZG5mIGNsZWFuIGFsbFwKCSYmIG1pY3JvZG5mIGluc3RhbGwgLXkgXAogICAgdW56aXAgXAogICAgd2dldCBcCiAgICBjdXJsIFwKICAgIHZpIFwKICAgIHRhciBcCiAgICBuZXQtdG9vbHMgXAogICAgb3BlbnNzaC1zZXJ2ZXIKCiNVcGRhdGUgdG8gY3VybAojQ09QWSBJQk1fTU9CSUxFRklSU1RfUExBVEZPUk1fRk9VTkRBVEkuemlwIC8KUlVOIHdnZXQgaHR0cHM6Ly9yZXBvcy5hbXhkaWdpdGFsLm5ldC9tb2JpbGUtZmlyc3QtOC0wLTAvSUJNX01PQklMRUZJUlNUX1BMQVRGT1JNX0ZPVU5EQVRJLnppcCAtUCAvIFwKICAgICYmIG1rZGlyIC1wIC9Nb2JpbGVGaXJzdCBcCiAgICAmJiB1bnppcCAvSUJNX01PQklMRUZJUlNUX1BMQVRGT1JNX0ZPVU5EQVRJLnppcCAtZCAvTW9iaWxlRmlyc3QgXAogICAgJiYgcm0gLWYgSUJNX01PQklMRUZJUlNUX1BMQVRGT1JNX0ZPVU5EQVRJLnppcAoKIyBFeHBvc2UgcG9ydCA1NDMyODogVGhlIGVsYXN0aWMgc2VhcmNoIHRyYW5zcG9ydCBwb3J0IGZvciBtdWx0aWNhc3QgIApFWFBPU0UgNTQzMjgKICAKRU5WIEpBVkFfSE9NRSAvb3B0L2libS9pYm0tamF2YS14ODZfNjQtODAKRU5WIExJQ0VOU0UgYWNjZXB0CgojIFNTSApSVU4gbWtkaXIgLXAgL3Zhci9ydW4vc3NoZCAmJlwKICAgIG1rZGlyIC1wIC9yb290Ly5zc2gvICYmXAogICAgbWtkaXIgLXAgL3Jvb3Qvc3Noa2V5LyAmJlwKICAgIHRvdWNoIC9yb290Ly5zc2gvYXV0aG9yaXplZF9rZXlzICYmXAogICAgc2VkIC1pICdzL3Nlc3Npb24gXCtyZXF1aXJlZCBcK3BhbV9sb2dpbnVpZFwuc28vc2Vzc2lvbiBvcHRpb25hbCBwYW1fbG9naW51aWQuc28vJyAvZXRjL3BhbS5kL3NzaGQgJiZcCiAgICBzZWQgLWkgJ3MvLipQYXNzd29yZEF1dGhlbnRpY2F0aW9uIHllcy9QYXNzd29yZEF1dGhlbnRpY2F0aW9uIG5vL2cnIC9ldGMvc3NoL3NzaGRfY29uZmlnICYmXAogICAgc2VkIC1pICdzLy4qVXNlUEFNIHllcy9Vc2VQQU0gbm8vZycgL2V0Yy9zc2gvc3NoZF9jb25maWcgJiZcCiAgICBzZWQgLWkgJ3MvLipDaGFsbGVuZ2VSZXNwb25zZUF1dGhlbnRpY2F0aW9uIHllcy9DaGFsbGVuZ2VSZXNwb25zZUF1dGhlbnRpY2F0aW9uIG5vL2cnIC9ldGMvc3NoL3NzaGRfY29uZmlnCgojIFNldCBwYXNzd29yZCBsZW5ndGggYW5kIGV4cGlyeSBmb3IgY29tcGxpYW5jZSB3aXRoIFZ1bG5lcmFiaWxpdHkgQWR2aXNvciAobWFudGVuZXIpClJVTiBzZWQgLWkgJ3MvXlBBU1NfTUFYX0RBWVMuKi9QQVNTX01BWF9EQVlTICAgOTAvJyAvZXRjL2xvZ2luLmRlZnMgXAogICAgJiYgc2VkIC1pICdzL3NoYTUxMi9zaGE1MTIgIG1pbmxlbj04LycgL2V0Yy9wYW0uZC9zeXN0ZW0tYXV0aAoKQ09QWSBlbnRyeXBvaW50LnNoIC9yb290ClJVTiBjaG1vZCAreCAvcm9vdC9lbnRyeXBvaW50LnNoCkVOVFJZUE9JTlQgWyIvcm9vdC9lbnRyeXBvaW50LnNoIiBd' | base64 -w0 -d > /opt/MFAnalytics/Dockerfile
```

Crear el entrypoint.sh
```sh
echo 'IyEvYmluL2Jhc2gKCiNWYXJpYWJsZXMKI0FOQUxZVElDU19BRE1JTl9VU0VSPWFkbWluCiNBTkFMWVRJQ1NfQURNSU5fUEFTU1dPUkQ9YWRtaW4KCmZ1bmN0aW9uIGNoZWNrX3ZhcmlhYmxlcygpewogICAgaWYgWyAhIC16ICIke0FOQUxZVElDU19BRE1JTl9VU0VSfSIgXTsgdGhlbgogICAgICAgIHNlZCAtaSAicy9BTkFMWVRJQ1NfQURNSU5fVVNFUj1hZG1pbi9BTkFMWVRJQ1NfQURNSU5fVVNFUj0ke0FOQUxZVElDU19BRE1JTl9VU0VSfS9nIiAvb3B0L2libS93bHAvdXNyL3NlcnZlcnMvbWZwL3NlcnZlci5lbnYKICAgIGVsc2UKICAgICAgICBlY2hvICJbQU1YXSBBTkFMWVRJQ1NfQURNSU5fVVNFUiBub3QgZm91bmQiCiAgICAgICAgZXhpdCAxCiAgICBmaQoKICAgIGlmIFsgISAteiAiJHtBTkFMWVRJQ1NfQURNSU5fUEFTU1dPUkR9IiBdOyB0aGVuCiAgICAgICAgc2VkIC1pICJzL0FOQUxZVElDU19BRE1JTl9QQVNTV09SRD1hZG1pbi9BTkFMWVRJQ1NfQURNSU5fUEFTU1dPUkQ9JHtBTkFMWVRJQ1NfQURNSU5fUEFTU1dPUkR9L2ciIC9vcHQvaWJtL3dscC91c3Ivc2VydmVycy9tZnAvc2VydmVyLmVudgogICAgZWxzZQogICAgICAgIGVjaG8gIltBTVhdIEFOQUxZVElDU19BRE1JTl9QQVNTV09SRCBub3QgZm91bmQiCiAgICAgICAgZXhpdCAxCiAgICBmaQp9CgojRGVwZW5kZW5jaWFzCm1rZGlyIC1wIC9vcHQvaWJtCmNwIC9Nb2JpbGVGaXJzdC9kZXBlbmRlbmNpZXMvaWJtLWphdmEtanJlLTguMC01LjE3LWxpbnV4LXg4Nl82NF8qLnRneiAvb3B0L2libS8KdGFyIC14dmYgL29wdC9pYm0vKjEudGd6IC1DIC9vcHQvaWJtICYmIHRhciAteHZmIC9vcHQvaWJtLyoyLnRneiAtQyAvb3B0L2libSAmJiBybSAtZiAvb3B0L2libS8qLnRnegpta2RpciAtcCAvb3B0L2libS9kb2NrZXIvCmNwIC9Nb2JpbGVGaXJzdC9kZXBlbmRlbmNpZXMvbGljZW5zZS1jaGVjayAvb3B0L2libS9kb2NrZXIvCgpta2RpciAtcCAvb3B0L2libS9Nb2JpbGVGaXJzdC9zd2lkdGFnLwpjcCAvTW9iaWxlRmlyc3QvZGVwZW5kZW5jaWVzL2libS5jb21fSUJNX01vYmlsZUZpcnN0X1BsYXRmb3JtX0ZvdW5kYXRpb24tOC4wLjAuc3dpZHRhZyAvb3B0L2libS9Nb2JpbGVGaXJzdC9zd2lkdGFnLwoKIyBJbnN0YWxsIFdlYlNwaGVyZSBMaWJlcnR5CmNwIC9Nb2JpbGVGaXJzdC9kZXBlbmRlbmNpZXMvd2xwLWJhc2UtZW1iZWRkYWJsZS0xOC4wLjAuMl8qLnRhci5neiAvb3B0L2libS8KdGFyIC14dmYgL29wdC9pYm0vKjEudGFyLmd6IC1DIC9vcHQvaWJtICYmIHRhciAteHZmIC9vcHQvaWJtLyoyLnRhci5neiAtQyAvb3B0L2libSAmJiBybSAtZiAvb3B0L2libS8qLnRhci5negoKI0NyZWFjacOzbiBkZWwgc2Vydmlkb3IKL29wdC9pYm0vd2xwL2Jpbi9zZXJ2ZXIgY3JlYXRlIG1mcApybSAtcmYgL29wdC9pYm0vd2xwL3Vzci9zZXJ2ZXJzLy5jbGFzc0NhY2hlICYmIHJtIC1yZiAvb3B0L2libS93bHAvdXNyL3NlcnZlcnMvbWZwL2FwcHMvKgoKdGFyIC14dmYgL01vYmlsZUZpcnN0L21mcGYtbGlicy9tZnBmLWFuYWx5dGljcy50Z3ogLUMgLwpjcCAtciAvTW9iaWxlRmlyc3QvbGljZW5zZXMgL29wdC9pYm0vTW9iaWxlRmlyc3QvbGljZW5zZXMKCmNobW9kIHUreCAvb3B0L2libS9kb2NrZXIvbGljZW5zZS1jaGVjawpjaG1vZCB1K3ggL29wdC9pYm0vd2xwL2Jpbi9saWJlcnR5LXJ1bgoKI0NvbmZpZ3VyYWNpw7NuIGRlbCBzZXJ2ZXIKY3AgL01vYmlsZUZpcnN0L21mcGYtYW5hbHl0aWNzL3Vzci9iaW4vbWZwLWluaXQgL29wdC9pYm0vd2xwL2Jpbi8KY2htb2QgdSt4IC9vcHQvaWJtL3dscC9iaW4vbWZwLWluaXQKbWtkaXIgLXAgL29wdC9pYm0vd2xwL3Vzci9zZXJ2ZXJzL21mcC9yZXNvdXJjZXMvc2VjdXJpdHkvCmNwIC1yIC9Nb2JpbGVGaXJzdC9tZnBmLWFuYWx5dGljcy91c3Ivc2VjdXJpdHkvKiAvb3B0L2libS93bHAvdXNyL3NlcnZlcnMvbWZwL3Jlc291cmNlcy9zZWN1cml0eS8KY3AgLXIgL01vYmlsZUZpcnN0L21mcGYtYW5hbHl0aWNzL3Vzci9qcmUtc2VjdXJpdHkvKiAvb3B0L2libS9pYm0tamF2YS14ODZfNjQtODAvanJlL2xpYi9zZWN1cml0eS8KY3AgLXIgL01vYmlsZUZpcnN0L21mcGYtYW5hbHl0aWNzL3Vzci9lbnYvKiAvb3B0L2libS93bHAvdXNyL3NlcnZlcnMvbWZwLwpjcCAtciAvTW9iaWxlRmlyc3QvbWZwZi1hbmFseXRpY3MvdXNyL3NzaC8qIC9yb290L3NzaGtleS8KbWtkaXIgLXAgL29wdC9pYm0vd2xwL3Vzci9zZXJ2ZXJzL21mcC9jb25maWdEcm9waW5zL292ZXJyaWRlcy8KY3AgLXIgL01vYmlsZUZpcnN0L21mcGYtYW5hbHl0aWNzL3Vzci9jb25maWcvKi54bWwgL29wdC9pYm0vd2xwL3Vzci9zZXJ2ZXJzL21mcC9jb25maWdEcm9waW5zL292ZXJyaWRlcy8KCiNWZXJpZmljYXIgdmFyaWFibGVzCmNoZWNrX3ZhcmlhYmxlcwoKI1ByZW5kZXIgc2Vydmlkb3IKI3doaWxlIDo7IGRvIGNkIC9vcHQvaWJtL3dscC9iaW4vICYmIC4vc2VydmVyIHN0YXJ0IG1mcDsgc2xlZXAgMjA7IGRvbmUKY2QgL29wdC9pYm0vd2xwL2Jpbi8gJiYgLi9zZXJ2ZXIgc3RhcnQgbWZwCgpmdW5jdGlvbiBkb2NrZXJfc3RvcCB7CiAgICBleHBvcnQgU1RPUF9QUk9DPTE7Cn0KCkVYSVRfREFFTU9OPTAKU1RPUF9QUk9DPTAKCndoaWxlIFsgJEVYSVRfREFFTU9OIC1lcSAwIF07IGRvCiAgICBpZiBbICRTVE9QX1BST0MgIT0gMCBdCiAgICB0aGVuCiAgICAgICAgZWNobyAiU3RhcnRpbmcgdGhlIFNlcnZlciIKICAgICAgICBjZCAvb3B0L2libS93bHAvYmluLyAmJiAuL3NlcnZlciBzdGFydCBtZnAKICAgICAgICBicmVhazsKICAgIGZpCiAgICBzbGVlcCA1CmRvbmU=' | base64 -w0 -d > /opt/MFAnalytics/entrypoint.sh
```
Construir la imagen.
```sh
docker build -t dockeregistry.amovildigitalops.com/rhel7-atomic-mfanalytics8 /opt/MFAnalytics
```
Levantar el contenedor.
```sh
docker run -td --name MFAnalytics \
           -p 9080:9080 \
           -p 54328:54328 \
           -e ANALYTICS_ADMIN_USER=amxga \
           -e ANALYTICS_ADMIN_PASSWORD=abcd1234 \
           dockeregistry.amovildigitalops.com/rhel7-atomic-mfanalytics8
```

## Verificar servicios

Verificamos que los servicios estén arriba en las rutas:

* **Mobilefirst Platform Server** http://\<host>:\<puerto>/mfpconsole/
* **Mobilefirst Platform Analytics** http://\<host>:\<puerto>/analytics/console