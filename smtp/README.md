# Smtp

## Prerequisitos

* Imagen docker dockeregistry.amovildigitalops.com/centos68mailserver

## Desarrollo

### Despliegue del servidor Smtp

Para llevar a cabo el despliegue del servidor Smtp hacemos uso del siguente runit:

```bash
mkdir -p /var/containers/mailserver/{etc/postfix,var/lib/postfix,var/spool/postfix}
mkdir -p /var/containers/mailserver/{var/lib/imap,var/spool/imap,etc/lib/imap,var/log}

docker run -td  --name=mailserver -p 25:25  --privileged=true --net=host \
                --volume=/var/containers/mailserver/etc/postfix:/etc/postfix/ \
                --volume=/var/containers/mailserver/var/lib/postfix:/var/lib/postfix \
                --volume=/var/containers/mailserver/var/spool/postfix:/var/spool/postfix \
                --volume=/var/containers/mailserver/var/lib/imap:/var/lib/imap \
                --volume=/var/containers/mailserver/var/spool/imap:/var/spool/imap \
                --volume=/var/containers/mailserver/etc/lib/imap:/etc/lib/imap \
                --volume=/var/containers/mailserver/var/log:/var/log \
                --volume=/etc/localtime:/etc/localtime:ro \
                dockeregistry.amovildigitalops.com/centos68mailserver
```

### Relay entre servidores Smtp

**NOTA**: Antes de llevar a cabo la configuración del relay entre servidores smtp es necesario contar con el **Usuario** y **Contraseña** del servidor al que se realizará dicho relay.

*A continuación todos los comandos que se muestran en esta guía deberán ejecutarse en la máquina **host**, fuera del contenedor.*

Modificamos la configuración de Postfix indicando el servidor smtp con el que se llevará a cabo el relay.

Hacemos uso de unas variables en bash, en donde indicaremos el hostname o ip del servidor y puerto al que se realizará el relay, a continuación se muestra un ejemplo utilizando el stmp de gmail.


```bash
SMTP_RELAY_HOST=smtp.gmail.com
SMTP_RELAY_PORT=587
```

Enseguida agregamos las sentencias que permitirán el relay entre smtp con el siguiente comando.

```bash
cat<<EOF >>/var/containers/mailserver/etc/postfix/main.cf
relayhost = [$SMTP_RELAY_HOST]:$SMTP_RELAY_PORT
smtp_sasl_tls_security_options = noanonymous
smtpd_tls_auth_only = no
smtp_tls_security_level=may
EOF
```

Tras la modificación en el archivo de configuración de Postfix, agregamos el usuario y contraseña con el que se llevará a cabo el relay de los correos, para ello hacemos uso de las siguientes variables y el siguiente comando.

```bash
SMTP_RELAY_USER=amxgadt
SMTP_RELAY_PASSWORD=Gerencia.Arquitectura
```

```bash
echo "[$SMTP_RELAY_HOST]:$SMTP_RELAY_PORT     $SMTP_RELAY_USER:$SMTP_RELAY_PASSWORD" >> /var/containers/mailserver/etc/postfix/maps/sasl_passwd
```

**NOTA**: Las variable *SMTP_RELAY_HOST* y *SMTP_RELAY_PORT* son las utilizadas en pasos anteriores.

Por último actualizamos las tablas de Postfix.

```bash
docker exec -it mailserver postmap /etc/postfix/maps/sasl_passwd
```

**NOTA**: En ocasiones el servicio **saslauthd** no se inicia correctamente, pero es importante para el funcionamiento de Postfix, para verificar su status ejecutamos:

```bash
docker exec -it mailserver /etc/rc.d/init.d/saslauthd status
```

Si el servicio se encuentra abajo, podemos iniciarlo con el comando:
```bash
docker exec -it mailserver /etc/rc.d/init.d/saslauthd start
```

Finalmente recargamos la configuración del servicio de Postfix

```bash
docker exec -it mailserver postfix reload
```

### Forwarding entre servidores smtp

*A continuación todos los comandos que se muestran en esta guía deberán ejecutarse en la máquina **host**, fuera del contenedor.*

Modificamos la configuración de Postfix indicando el servidor smtp con el que se llevará a cabo el forwarding.

Primero verificamos si la siguiente linea existe en el archivo de configuración de Postfix.

```bash
cat /var/containers/mailserver/etc/postfix/main.cf | grep transport_maps
```

En caso de que la sentencia no exista, la agregamos con el siguiente comando

```bash
echo "transport_maps = hash:/etc/postfix/transport" >> /var/containers/mailserver/etc/postfix/main.cf
```

A continuación hacemos uso de unas variables en bash, en donde indicaremos el hostname o ip del servidor y puerto al que se realizará el forwarding, a continuación se muestra un ejemplo utilizando el stmp de gmail.


```bash
SMTP_FORWARDING_HOST=smtp.gmail.com
SMTP_FORWARDING_PORT=25
```

Enseguida indicamos el servidor al que se realizará el forwarding con la siguiente instrucción

```bash
echo "*       smtp:[$SMTP_FORWARDING_HOST]:$SMTP_FORWARDING_PORT" >> /var/containers/mailserver/etc/postfix/transport
```

Por último actualizamos las tablas de Postfix.

```bash
docker exec -it mailserver postmap /etc/postfix/transport
```

**NOTA**: En ocasiones el servicio **saslauthd** no se inicia correctamente, pero es importante para el funcionamiento de Postfix, para verificar su status ejecutamos:

```bash
docker exec -it mailserver /etc/rc.d/init.d/saslauthd status
```

Si el servicio se encuentra abajo, podemos iniciarlo con el comando:
```bash
docker exec -it mailserver /etc/rc.d/init.d/saslauthd start
```

Finalmente recargamos la configuración del servicio de Postfix

```bash
docker exec -it mailserver postfix reload
```