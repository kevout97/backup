# Configuración Nginx

Las configuraciones que se muestran a continuación son validas cuando la firma de certificados es realizada con Letsencrypt.

## Prerequisitos

* Nginx >= 1.16.1
* Letsencrypt >= 1.0.0
* Subdominio asociado.
* Acceso a la configuración de zona donde se encuentra el subdominio asociado.
  
## Desarrollo

Para esta configuración suponemos que el subdominio asociado para exponer los diferentes servicios desplegados en OKD es **apps.okd.amx.gadt.amxdigital.net**. En cada uno de los comandos es preciso ajustarlos con el subdominio otorgado (basta con sustituir **apps.okd.amx.gadt.amxdigital.net**).

Primero generamos el certificado para el wildcard asociado a **\*.apps.okd.amx.gadt.amxdigital.net**

```bash
certbot certonly --manual -d *.apps.okd.amx.gadt.amxdigital.net -d apps.okd.amx.gadt.amxdigital.net --agree-tos --no-bootstrap --manual-public-ip-logging-ok --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
```

Durante el proceso de la creación del certificado, el cliente Certbot mostrará un mensaje como el siguiente:

```conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.apps.okd.amx.gadt.amxdigital.net with the following value:

EOo2Xx5qwGxr_jwm970MXVPpnb8gSAvNkrqUY2r0aNM

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

Es importante agregar dicho registro TXT en el archivo de zona que contiene la configuración del subdominio asociado. Un ejemplo de como luciria dicho archivo utilizando la herramienta Bind es el siguiente:

```conf
$TTL	3600
@   	IN  	SOA 	amx.gadt.amxdigital.net.  . (
             	1267456429  	; Serial
             	10800   ; Refresh
             	3600	; Retry
             	3600	; Expire
             	3600)   ; Minimum
 	IN      	NS  ns0
 	IN      	A   201.161.69.133;	

ns0       	    IN A         	201.161.69.133
*		        IN A            201.161.69.133
*.apps.okd      IN A            201.161.69.133
_acme-challenge.apps.okd  IN  TXT  XUJzyejF4VKPPy27ToxLUnI6VGMLhnAEpmfv1gDMwyU
```

Después de agregar dicha entrada continuamos con el proceso, una vez finalizado obtendremos un mensaje como el siguiente en el que se muestra la ubicación de los certificados ya creados.

```conf
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/apps.okd.amx.gadt.amxdigital.net/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/apps.okd.amx.gadt.amxdigital.net/privkey.pem
   Your cert will expire on 2020-07-19. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot again
   with the "certonly" option. To non-interactively renew *all* of
   your certificates, run "certbot renew"
```

A continuación generamos el archivo de configuración Nginx que dará de alta el subdominio:

```nginx
server {
    server_name  *.apps.okd.amx.gadt.amxdigital.net;
 
    proxy_max_temp_file_size 0;
    proxy_buffering off;

    location / {

        proxy_pass https://10.23.144.147$request_uri;
        proxy_set_header        Host           "$host";

        proxy_ssl_name $host;
        proxy_ssl_server_name on;
        proxy_ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
        proxy_ssl_session_reuse off;
        proxy_intercept_errors off;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header  X-Real-IP  $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        add_header Last-Modified $date_gmt;
        proxy_set_header Connection keep-alive;
        add_header Cache-Control 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
        if_modified_since off;
        expires off;
        etag off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        client_max_body_size 0;
    }

    location /auth/ {
        
        proxy_pass https://10.23.144.147$request_uri;
        proxy_set_header        Host           "$host";

        proxy_ssl_name $host;
        proxy_ssl_server_name on;
        proxy_ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
        proxy_ssl_session_reuse off;

        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Connection keep-alive;
        proxy_set_header  X-Real-IP  $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        add_header Last-Modified $date_gmt;
        add_header Cache-Control 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
        if_modified_since off;
        expires off;
        etag off;
        client_max_body_size 0;
    }

    proxy_hide_header X-Powered-By;
    proxy_hide_header Server;

    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/apps.okd.amx.gadt.amxdigital.net/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/apps.okd.amx.gadt.amxdigital.net/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
server {
    server_name  *.apps.okd.amx.gadt.amxdigital.net;
    listen 80;
    return 301 https://$host$request_uri;
}
```

Es importante ajustar las líneas, apuntando a los valores propios.

* server_name  *.apps.okd.amx.gadt.amxdigital.net;
* proxy_pass https://10.23.144.147$request_uri;
* ssl_certificate /etc/letsencrypt/live/apps.okd.amx.gadt.amxdigital.net/fullchain.pem;
* ssl_certificate_key /etc/letsencrypt/live/apps.okd.amx.gadt.amxdigital.net/privkey.pem;

**NOTA**: 

    El proxy_pass debe apuntarse al servidor cuya función es de Load Balancer.
    Los valores de las líneas ssl_certificate_key y ssl_certificate son los mismos arrojados por el cliente de certbot cuando fue creado el certificado.

Finalmente recargamos la configuración de Nginx.

```conf
nginx -s reload
```