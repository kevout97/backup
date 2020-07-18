# Opendkim

## Prerequisitos

* Imagen docker dockeregistry.amovildigitalops.com/atomic-rhel7-opendkim
* Permitir el tráfico en el puerto 8891
* Acceso al archivo de zona del dominio que se desea certifcar con dkim
* Contenedor de mailserver (dockeregistry.amovildigitalops.com/centos68mailserver)

## Construcción de la Imagen

El proceso para llevar acabo la construcción de la imagen se muestra en el siguiente apartado [Construcción Opendkim](Build.md)

## Desarrollo

En el servidor donde se encuentra desplegado el contenedor de mailserver, realizamos el despliegue del contenedor de Dkim con el siguiente runit

```
OPENDKIM_CONTAINER=opendkim
OPENDKIM_DOMAIN=dkim.amx.gadt.amxdigital.net # Dominio al que se añadira Dkim

docker run -itd --name $OPENDKIM_CONTAINER \
    -v /etc/localtime:/etc/localtime:ro \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -e "TZ=America/Mexico_City" \
    -e "OPENDKIM_DOMAIN=$OPENDKIM_DOMAIN" \
    -p 8891:8891 \
    dockeregistry.amovildigitalops.com/atomic-rhel7-opendkim
```
Donde:
* **OPENDKIM_DOMAIN**: Es el dominio de correo electronico.

En los logs del contenedor podremos observar una salida como la siguiente:

```log
[AMX 2020-04-02 10:35] Configuring dkim for dkim.amx.gadt.amxdigital.net...
[AMX 2020-04-02 10:35] Configuration was successful
[AMX 2020-04-02 10:35] Put this on your file dns zone, without brackets
#########################################
$ORIGIN dkim.amx.gadt.amxdigital.net
default._domainkey	IN	TXT	( "v=DKIM1; k=rsa; s=email; "
	  "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDXALCt5rv5CDCcgdl6bTeKneLaPLqsGdTcMT+cTyp8uOvzlUTIUv59kRjI86h0dJZu7InYsdMOoDBq1nGSqQKBmIrWXweS7ZwZ8QCV57eogzCVcAptZc7qdMwidtQpakGJF7tsiajjXOSexpuZPF1pmBaUSgwzj6pa8dTmLArLVwIDAQAB" )  ; ----- DKIM key default for dkim.amx.gadt.amxdigital.net
#########################################

[AMX 2020-04-02 10:35] Add these lines at the end on your main.cf of your postfix service
#########################################
smtpd_milters = inet:0.0.0.0:8891
non_smtpd_milters = $smtpd_milters
milter_default_action = accept
#########################################

[AMX 2020-04-02 10:35] Starting Opendkim...
[AMX 2020-04-02 10:35] Started Opendkim
```

A continuación en la configuración del contenedor de mailserver es importante agregar las siguientes líneas al final del archivo de configuración de postfix, **/var/containers/mailserver/etc/postfix/main.cf**, en caso de que estas no se encuentren.

```
smtpd_milters = inet:0.0.0.0:8891
non_smtpd_milters = $smtpd_milters
milter_default_action = accept
```

Para que los cambios tengan efecto es necesario recargar el servicio de postfix y saslauthd.

```
docker exec -it mailserver postfix reload
dokcer exec -it mailserver /etc/init.d/saslauthd restart
```

A continuación al final del archivo de zona agregar el registro TXT mostrado en los logs del contendor de dkim, al agregar dicho registro se recomienda que sea en dos líneas y sin los paréntesis. Importante cuidar que solo se tenga unas comillas de apertura y de cierre.

E.g.
```
$ORIGIN OPENDKIM_DOMAIN
default._domainkey	IN	TXT	"v=DKIM1; k=rsa; s=email;
p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDXALCt5rv5CDCcgdl6bTeKneLaPLqsGdTcMT+cTyp8uOvzlUTIUv59kRjI86h0dJZu7InYsdMOoDBq1nGSqQKBmIrWXweS7ZwZ8QCV57eogzCVcAptZc7qdMwidtQpakGJF7tsiajjXOSexpuZPF1pmBaUSgwzj6pa8dTmLArLVwIDAQAB"
```
**NOTA**: Sustituir *OPENDKIM_DOMAIN* por el dominio de correo electrónico.

**NOTA**: Para que los cambios tengan efecto es necesario recargar o reiniciar el servicio de DNS.