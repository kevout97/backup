# Freeipa

Es una solución de gestión de información de seguridad integrada que combina Linux, 389 Directory Server, Mit Kerberos, NTP, DNS y Dogtag. 
FreeIPA es una solución integrada de identidad y autenticación para entornos de red Linux / UNIX, proporciona autenticación centralizada, autorización e información de cuenta al almacenar datos sobre usuarios, grupos, hosts.

FreeIPA se basa en componentes de código abierto y en los protocolos estándar, con un fuerte enfoque en la facilidad de administración y automatización de las tareas de instalación y configuración: El 389 Directory Server es el almacén de datos principal y proporciona una infraestructura de directorio LDAPv3 multi-master completa. La autenticación de inicio de sesión único se proporciona a través del MIT Kerberos KDC. Las capacidades de autenticación se aumentan mediante una autoridad de certificación integrada basada en el proyecto Dogtag. Opcionalmente, los nombres de dominio se pueden administrar mediante el servidor ISC Bind integrado.
Los aspectos de seguridad relacionados con el control de acceso, la delegación de tareas de administración y otras tareas de administración de red se pueden centralizar y administrar completamente a través de la interfaz de usuario web o la herramienta de línea de comandos ipa.

### Clonación de repositorio FreeIPA
```bash
git clone https://github.com/freeipa/freeipa-container.git
```

### Construcción de la imagen para FreeIPA basada en Centos 7
```bash
docker build -f Dockerfile.centos-7 -t freeipa-server .
```
### Creación de directorio para datos persistentes
```bash
mkdir -p /var/containers/freeipa/var/lib/ipa-data
```
### En caso de tener Selinux activado en máquina host
```bash
setsebool -P container_manage_cgroup 1
```
### Levantamiento del contenedor
```bash
docker run --name freeipa -ti \
           -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
           --tmpfs /run \
           --tmpfs /tmp \
           -v /var/containers/freeipa/var/lib/ipa-data:/data:Z \
           -h ipa.example.com \
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
            freeipa-server
```
### Instalación y Setup de FreeIPA
La instalación y setup de FreeIPA inicia al levantar por primera vez el contenedor, aquí nos pedirá cierta información requerida por el servidor FreIPA para su funcionamiento.

Información acerca de los puertos utilizados: 
* HTTP/HTTPS 80 443 - TCP -
* LDAP/LDAPS 389 636 - TCP -
* Kerberos 88 464 -TCP UDP -
* DNS 53 - TCP UDP -
* NTP 123 - UDP -

# Agregar Cliente

###### Pre-requisitos: 
El nombre del servidor y cliente deben resolverse por FQDN
##### Instalación de paquete
```bash
yum install freeipa-client
```
##### Alta y configuración del cliente
```bash
ipa-client-install --hostname client.example.test --mkhomedir
```
Se ingresan los datos requeridos. Una vez que el usaurio ha sido agregado con éxito, se listará dentro de **Identity > Hosts** 

# Alta y configuración de usuarios.
##### Agregar usuario
En **Identity > Users > +add** 
Se registra el nuevo usuario a un nuevo usuario, se ingresan los datos correspondientes así como una contraseña, esta expirará cuando el usario inicie sesión por primera vez por tal motivo el usario debe ingresar una nueva contraseña. Dependiendo al grupo que correspondan tendrán privilegios. 
Una vez agregado en **Identity > Users > usuario_agregado** se puede modificar su información correspondiete, agregar el modo de autenticación así como la generación de Token. 
##### Generación de OTP
Dentro de **Identity > Users > usuario_agregado > action > add OTP Token** se registra al usuario y finalmente se genera un código QR para ser escaneado con FreeOTP.
![Menú](https://gitlab.ctin-uat.amxdigital.net/el-laure5/freeipa/raw/master/Images/menuotpcap.png)
![Generación](https://gitlab.ctin-uat.amxdigital.net/el-laure5/freeipa/raw/master/Images/otpcreatingcap.png)
![QR code](https://gitlab.ctin-uat.amxdigital.net/el-laure5/freeipa/raw/master/Images/otpqrcap.png)
##### SSH via contraseña + OTP 
Para activar está forma de autenticación, en las configuraciones del usuario **Identity > Users > usuario_agregado > Account Settings** se selecciona la opción **Two factor authentication (password + OTP)**, se guardan los cambios y con esto el usuario deberá ingresar su contraseña y el token correspondiente para ingresar al servidor. 
Ejemplo de ingreso via SSH 
```bash
$ssh example@xx.xx.xx.xx
First Factor: 
Second Factor:
```
##### SSH via contraseña + OTP 
Por otro lado, si se desea ingresar a través de una llave pública SSH, en **Identity > Users > usuario_agregado > Account Settings** se agrega la llave correspondiente del usuario.

Esta opción no solicitará contraseña aún cuando la opción de **Two factor authentication (password + OTP)** se encuetre seleccionada. 

Por defecto, si no se activa ninguna de las anteriores opciones, el ingreso al servidor via SSH se realiza a través de la contraseña del usuario.


