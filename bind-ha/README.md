# Dns con alta disponibilidad (Bind)

## Prerequisitos

* Virtual CentOS/Rhel 7
* Docker 1.13.X
* Imagen dockeregistry.amovildigitalops.com/rhel7-atomic
* Permitir el tráfico por los puertos 53 tanto de TCP como UDP del servidor.

## Desarrollo

### Creación de la imagen

Clonar el repositorio
```sh
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/bind-ha.git /opt/bind-ha
```
Construir la imagen
```sh
docker build -t dockeregistry.amovildigitalops.com/atomic-rhel7-bind /opt/bind-ha/docker/
```

### Configuración de nodo Master

*NOTA: Todos los comandos deberán ser ejecutados directo en el host. NO ENTRAR AL CONTENEDOR.*

Desplegar el contenedor de Bind. Creamos y ejecutamos el siguiente archivo.

```bash
#!/bin/bash

#######################################
#                                     #
#             Runit Bind 9            #
#                                     #
#######################################

BIND_CONTAINER="bind"
BIND_DOMAIN="san.gadt.amxdigital.net"

mkdir -p /var/containers/$BIND_CONTAINER{/var/named/views/,/var/named/zones/,/etc/named} -p
chown 25:0 -R /var/containers/$BIND_CONTAINER

docker run -itd --name $BIND_CONTAINER \
    -p 53:53/tcp \
    -p 53:53/udp \
    -h $BIND_CONTAINER.$BIND_DOMAIN \
    -v /etc/localtime:/etc/localtime:ro \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /var/containers/$BIND_CONTAINER/var/named/views/:/var/named/views/:z \
    -v /var/containers/$BIND_CONTAINER/var/named/zones/:/var/named/zones/:z \
    -v /var/containers/$BIND_CONTAINER/etc/named:/etc/named:z \
    -e "TZ=America/Mexico_City" \
    dockeregistry.amovildigitalops.com/atomic-rhel7-bind
```

**Donde**:
* **BIND_CONTAINER**: Es el nombre del asociado a dicho contenedor
* **BIND_DOMAIN**: Es el dominio al que pertenece dicho contenedor, esta variable s utilizada para la creación del FQDN del contenedor.

Agregamos la zona, en el achivo */var/containers/\<nombre del contenedor>/var/named/views/views.conf*

Para este ejemplo agregaremos una zona llamada "amxga.net" dicha zona estará situada en la vista *war-zone-view*, por lo que la configuración quedaría de la siguiente forma:

**NOTA:** Cada IP deberá estar separa por un “;”.

```sh
view "war-zone-view" {
    match-clients { any; };
    # new-war-zone-view-zone-line
    zone "amxga.net" IN { 
       type master;
       file "zones/amxga.net";
       allow-transfer { <Ip servidores esclavos>; };
       also-notify { <Ip servidores esclavos>; };
         notify yes;          
     };
};
```
**NOTA: Para posteriores Zonas, la directiva "file" tendrá el siguiente aspecto
zones/\<archivo correspondiente a la zona creada\>**

Creamos el archivo de zona ubicado en **/var/containers/\<nombre del contenedor>/var/named/zones/**

Para nuestro ejemplo el archivo se llamará **amxga.net** y su contenido será el que se muestra a continuación:

```bash
 $TTL	3600
 @   	IN  	SOA 	amxga.net.  . (
             	1267456417  	; Serial
             	10800   ; Refresh
             	3600	; Retry
             	3600	; Expire
             	3600)   ; Minimum
 	IN      	NS  ns0
 	IN      	NS  slave
 	IN      	A   <ip del servidor maestro> ;
 	IN      	A   <ip del servidor esclavo> ;

 ns0       	IN A    	<ip del servidor maestro> ;
 slave     	IN A    	<ip del servidor esclavo> ;
```

Reiniciamos el contenedor de Bind para hacer efectivos los cambios.

```bash
docker restart <nombre del contenedor bind>
```

**NOTA: Cada vez que realice una actualización en los archivos de zona, es importante incrementar el serial del registro SOA, eso permite que las modificaciones se repliquen de manera automática a los servidores esclavos.**

De igual forma es necesario reiniciar el contenedor de Bind para hacer efectivos los cambios

```bash
docker restart <nombre del contenedor bind>
```

### Configuración de nodo Slave

*NOTA: Todos los comandos deberán ser ejecutados directo en el host. NO ENTRAR AL CONTENEDOR.*

Desplegar el contenedor de Bind. Creamos y ejecutamos el siguiente archivo.

```sh
#!/bin/bash

#######################################
#                                     #
#             Runit Bind 9            #
#                                     #
#######################################

BIND_CONTAINER="bind"
BIND_DOMAIN="san.gadt.amxdigital.net"

mkdir -p /var/containers/$BIND_CONTAINER{/var/named/views/,/var/named/zones/} -p
chown 25:0 -R /var/containers/$BIND_CONTAINER

docker run -itd --name $BIND_CONTAINER \
    -p 53:53/tcp \
    -p 53:53/udp \
    -h $BIND_CONTAINER.$BIND_DOMAIN \
    -v /etc/localtime:/etc/localtime:ro \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /var/containers/$BIND_CONTAINER/var/named/views/:/var/named/views/:z \
    -v /var/containers/$BIND_CONTAINER/var/named/zones/:/var/named/zones/:z \
    -e "TZ=America/Mexico_City" \
    dockeregistry.amovildigitalops.com/atomic-rhel7-bind
```

**Donde**:
* **BIND_CONTAINER**: Es el nombre del asociado a dicho contenedor
* **BIND_DOMAIN**: Es el dominio al que pertenece dicho contenedor, esta variable s utilizada para la creación del FQDN del contenedor.

Agregamos la zona, en el achivo */var/containers/\<nombre del contenedor>/var/named/views/views.conf*

Para este ejemplo agregaremos una zona llamada "amxga.net" dicha zona estará situada en la vista *war-zone-view*, por lo que la configuración quedaría de la siguiente forma:

**NOTA: Cada IP maestra deberá estar separa por un “;”.**

```bash
view "war-zone-view" {
    match-clients { any; };
    # new-war-zone-view-zone-line
    zone "amxga.net" IN {                                                 
       type slave;                                                         
       file "zones/amxga.net";                              
       masters { <Ip servidores maestros>; };                                                                      
     };
};
```
Reiniciamos el contenedor de Bind para hacer efectivos los cambios.

```bash
docker restart <nombre del contenedor>
```

## Pruebas de funcionamiento.

Para probar el funcionamiento del servidor DNS y la réplica de las zonas, podemos utilizar el comando dig, haciendo unas peticiones tanto al servidor maestro como al esclavo.

La salida del comando dig debe ser la misma para ambos casos.

Para este ejemplo suponemos que hay una entrada al dominio **test.amxga.net**

```bash
dig @<ip del servidor maestro> test.amxga.net
```
Para este ejemplo suponemos que hay una entrada al dominio **test.amxga.net**

```bash
dig @<ip del servidor esclavo> test.amxga.net
```