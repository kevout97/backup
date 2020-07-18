# Setup DNS para OKD

Prerrequisitos:

+ Imagen dockeregistry.amovildigitalops.com/atomic-rhel7-bind
+ Dominio asociado al cluster de OKD, para esta configuración suponemos que se tiene control sobre el dominio **cs.gadt.amxdigital.net**, caso contrario ajustar a la configuración propia.

Reglas de firewall para tráfico dns.

```sh
firewall-cmd --permanent --add-port=53/tcp
firewall-cmd --permanent --add-port=53/udp
firewall-cmd --reload
```

Runit para levantar contenedor Bind.

```sh

#######################################
#                                     #
#             Runit Bind 9            #
#                                     #
#######################################

BIND_CONTAINER="bind"
BIND_DOMAIN="cs.gadt.amxdigital.net" # Dominio asociado

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

Configuraciones ejemplo para vistas y zonas.

> E.g. contenido del archivo /var/containers/$BIND_CONTAINER/var/named/views/views.conf

> Para esta configuración se creo la zona **okd.cs.gadt.amxdigital.net** en la cual residen los nodos de OKD, la zona **dcv.cs.gadt.amxdigital.net** hace referencia al resto de los servidores que hay en el datacenter

> En la zona interna (*internal-zone*) es preciso pertimitir peticiones desde la DMZ y la VLAN 3, para esta configuración dichos segmentos de red son 10.10.26.0/25; 10.10.27.0/25; respectivamente.

> En la zona externa (*external-zone*) deberá resolver peticiones de cualquier lado.

```sh
view "internal-zone" {
    match-clients { 10.10.26.0/25; 10.10.27.0/25; };
    zone "okd.cs.gadt.amxdigital.net" IN {
       type master;
       file "zones/internal/okd.cs.gadt.amxdigital.net";
     };
    zone "dcv.cs.gadt.amxdigital.net" IN {
       type master;
       file "zones/internal/dcv.cs.gadt.amxdigital.net";
     };
};
view "external-zone" {
    match-clients { any; };
    zone "cs.gadt.amxdigital.net" IN {
       type master;
       file "zones/external/cs.gadt.amxdigital.net";
     };
};
```

> E.g. contenido del archivo /var/containers/$BIND_CONTAINER/var/named/zones/internal/okd.cs.gadt.amxdigital.net

> Aqui se configura el wildcard asociado a OKD con el que se expondrán las aplicaciones desplegadas dentro de OKD, en este ejemplo dicha línea es ``` *.apps.okd      IN A            200.57.183.50 ``` la cual apunta al servidor Nginx.

```sh
$TTL 3600
@       IN      SOA     okd.cs.gadt.amxdigital.net.  . (
                1267456419      ; Serial
                10800   ; Refresh
                3600    ; Retry
                3600    ; Expire
                1)      ; Minimum
        IN              NS  ns0
        IN              A   10.10.26.3;
ns0             IN A            10.10.27.3
csmast01-1      IN A            10.10.27.4
cslb01-1        IN A            10.10.27.5
csinfra01-1     IN A            10.10.27.6
consola         IN A            10.10.27.6
csapp01-1       IN A            10.10.27.7
*.apps          IN A            200.57.183.50
```

> E.g. contenido del archivo /var/containers/$BIND_CONTAINER/var/named/zones/internal/dcv.cs.gadt.amxdigital.net

```sh
$TTL 3600
@       IN      SOA     okd.cs.gadt.amxdigital.net.  . (
                1267456419      ; Serial
                10800   ; Refresh
                3600    ; Retry
                3600    ; Expire
                1)      ; Minimum
        IN              NS  ns0
        IN              A   10.10.26.3;
ns0             IN A            10.10.26.3
csjablab      IN A              10.10.26.11
```

> E.g. contenido del archivo /var/containers/$BIND_CONTAINER/var/named/zones/external/cs.gadt.amxdigital.net

> Aqui se configura el wildcard asociado a OKD con el que se expondrán las aplicaciones desplegadas dentro de OKD, en este ejemplo dicha línea es ``` *.apps.okd      IN A            200.57.183.50 ``` la cual apunta al servidor Nginx.


```sh
$TTL    3600
@       IN      SOA     cs.gadt.amxdigital.net.  . (
                1267456429      ; Serial
                10800   ; Refresh
                3600    ; Retry
                3600    ; Expire
                1)      ; Minimum
        IN              NS  ns0
        IN              A   200.57.183.50;
ns0             IN A            200.57.183.50
*               IN A            200.57.183.50
*.apps.okd      IN A            200.57.183.50
```