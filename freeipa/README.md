# Instructivo de despliegue de Free IPA

## Prerrequisitos

+ Virtual con redhat 7.x / centos 7.x
+ Docker >= 1.13
+ Git
+ Imagen Docker dockeregistry.amovildigitalops.com/rhel7-atomic
## Desarrollo

Clonar el repositorio de git de para crear la imagen de Free IPA.
```bash
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/freeipa.git /opt/freeipa
```

Construir la imagen basada en Rhel 7.
```bash
docker build -t dockeregistry.amovildigitalops.com/rhel7-atomic-freeipa:4.6.5 /opt/freeipa/docker
```
Crear directorio para archivos persistentes.
```bash
mkdir -p /var/containers/freeipa/var/lib/ipa-data
```
Si se tiene SeLinux activado, para lectura de cgroup por systemd.
```bash
setsebool -P container_manage_cgroup 1
```

Levantar el contenedor.
```bash
docker run --name freeipa -ti \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --tmpfs /run \
  --tmpfs /tmp \
  -v /var/containers/freeipa/var/lib/ipa-data:/data:z \
  -h ipa.san.gadt.amxdigital.net \
  -p 53:53/udp \
  -p 80:80 \
  -p 443:443 \
  -p 389:389 \
  -p 636:636 \
  -p 88:88 \
  -p 464:464 \
  -p 88:88/udp \
  -p 464:464/udp \
  -p 123:123/udp \
  -p 7389:7389 \
  -p 9443:9443 \
  -p 9444:9444 \
  -p 9445:9445 \
  --add-host ipasat.san.gadt.amxdigital.net:10.23.142.133 \
  dockeregistry.amovildigitalops.com/rhel7-atomic-freeipa:4.6.5
```

Donde:
* **-h**: FQDN de la instancia FreeIpa a desplegar (Obligatorio)
* **--add-host ipasat.san.gadt.amxdigital.net:10.23.142.133**: Representa el FQDN asociado a la otra instancia de Freeipa. Recomendamos el uso de un servidor DNS para evitar este tipo de entradas en el runit.

Instalación y Setup de FreeIPA.

La instalación y setup de FreeIPA inicia al levantar por primera vez el contenedor, aquí nos pedirá cierta información requerida por el servidor FreeIPA para su funcionamiento.

Información acerca de los puertos utilizados:
```bash
HTTP/HTTPS 80 443 - TCP -
LDAP/LDAPS 389 636 - TCP -
Kerberos 88 464 - TCP UDP -
DNS 53 - TCP UDP -
NTP 123 - UDP -
```

# Instalación de un cliente de Free IPA

## Desarrollo

Prerrequisitos:
El nombre del servidor y cliente deben resolverse por FQDN</

Instalar paquete.
```bash
yum install freeipa-client
```

Alta y configuración del cliente.
```bash
ipa-client-install --hostname client.example.hostname --mkhomedir
```
Se ingresan los datos requeridos. Una vez que el usuario ha sido agregado con éxito, se listará dentro de Identity > Hosts.

# Instalación de réplica para Free IPA

## Desarrollo

Prerrequisitos:
Imagen de Free IPA
    
Crear directorio para archivos persistentes.
```bash
mkdir -p /var/containers/freeipa/var/lib/ipa-data
```

Si se tiene SeLinux activado, para lectura de cgroup por systemd.
```bash
setsebool -P container_manage_cgroup 1
```
Levantar el contenedor.
```bash
docker run --name freeipa -ti \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --tmpfs /run \
    --tmpfs /tmp \
    -v /var/containers/freeipa/var/lib/ipa-data:/data:Z \
    -h ipasat.san.gadt.amxdigital.net \
    -p 53:53/udp \
    -p 80:80 \
    -p 443:443 \
    -p 636:636 \
    -p 389:389 \
    -p 88:88 \
    -p 464:464 \
    -p 88:88/udp \
    -p 464:464/udp \
    -p 123:123/udp \
    -p 7389:7389 \
    -p 9443:9443 \
    -p 9444:9444 \
    -p 9445:9445 \
    --add-host ipa.san.gadt.amxdigital.net:10.23.142.134 \
    dockeregistry.amovildigitalops.com/rhel7-atomic-freeipa:4.6.5 ipa-replica-install --admin-password=abcd1234 --domain=san.gadt.amxdigital.net --server=ipa.san.gadt.amxdigital.net --realm=SAN.GADT.AMXDIGITAL.NET
```
Donde
* **--admin-password**: Password del usuario admin configurado en el servidor Master
* **--domain**: Dominio de Ipa
* **--server**: FQDN del servidor Master
* **--realm**: Realm configurado en el servidor Master
* **-h**: FQDN de la instancia FreeIpa a  (Obligatorio)
* **--add-host ipa.san.gadt.amxdigital.net:10.23.142.134**: FQDN asociado al servidor Master. Recomendamos el uso de un servidor DNS para evitar este tipo de entradas en el runit.

**NOTA**: Los servidores (Master y Slaves) deben conocerse entre si a traves de nombre de dominio, para el despliegue anterior podemos observar que se agrego al momento de desplegar cada contenedor la entrada del otro server con **--add-host**.

# Administración de FreeIPA

Para el manejo y administración de FreeIPA revisar:

**[Guía de Administración FreeIPA](AdministracionFreeipa.md)**
