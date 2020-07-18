# Owasp Zaproxy

## Prerequisitos

* Virtual Rhel/CentOS 7
* Docker 1.13.X
* Git
* Imagen Docker dockeregistry.amovildigitalops.com/rhel7-atomic

## Desarrollo

Clonar repositorio git.
```sh
git clone https://infracode.amxdigital.net/desarrollo-tecnologico/owasp-zap.git /opt/owasp-zap
```

Construir imagen.
```sh
docker build -t dockeregistry.amovildigitalops.com/atomic-rhel7-owasp-zap /opt/owasp-zap/docker
```

Levantar el contenedor con el siguiente runit.
```sh
mkdir -p /var/containers/owasp-zaproxy/opt/owasp-zaproxy/{sesiones,files}
chown 1001:0 -R /var/containers/owasp-zaproxy/

docker run -itd --name owasp-zaproxy \
    -h zap.example.com \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/owasp-zaproxy/opt/owasp-zaproxy/sesiones:/opt/owasp-zaproxy/sesiones:z \
    -v /var/containers/owasp-zaproxy/opt/owasp-zaproxy/files:/opt/owasp-zaproxy/files:z \
    -e ZAP_FULL_SCAN=false \
    -e TZ=America/Mexico_City \
    -p 9090:9090 \
    -p 8080:8080 \
    dockeregistry.amovildigitalops.com/atomic-rhel7-owasp-zap
```
Donde:
+ El Api se Zaproxy se expone por el puerto 9090.
+ El servicio web se expone por el puerto 8080.
+ ZAP_FULL_SCAN = Sólo se habilita para el modo de escaneo completo

**NOTA:** Para el uso de Zaproxy usar /opt/owasp-zaproxy/sesiones para guardar las sesiones, si se utiliza algún otro directorio, éstas no serán persistentes.

## Exponer con Nginx.

Para exponer el servicio con Nginx, existen dos maneras.

+ Proxy pass a sólo la interfaz web.
+ Proxy pass a donde escucha el servicor y a la interfaz web.

### Sólo interfaz web

```sh
server {
    server_name  zap.example.com;
    
    location / {
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_pass              http://10.23.142.134:9090$request_uri; # Para este ejemplo el puerto 9090 es por donde se esta exponiendo Zaproxy Proxy
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Host $host:9090; # Para este ejemplo el puerto 9090 es por donde se esta exponiendo Zaproxy Proxy
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/zap.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/zap.example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = zap.example.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen       80;
    server_name  zap.example.com;
    return 404; # managed by Certbot


}

```

### Interfaz web y Servidor ZAP

```sh
server {
    server_name  zap.example.com;
    
    location / {
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_pass              http://10.23.142.134:9090$request_uri; # Para este ejemplo el puerto 9090 es por donde se esta exponiendo Zaproxy Proxy
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Host $host:9090; # Para este ejemplo el puerto 9090 es por donde se esta exponiendo Zaproxy Proxy
    }

    location /zap {
        proxy_pass              http://10.23.142.134:8080$request_uri; # Para este ejemplo el puerto 8080 es por donde se esta exponiendo Zaproxy Web
	proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Host $host;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/zap.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/zap.example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = zap.example.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen       80;
    server_name  zap.example.com;
    return 404; # managed by Certbot


}
```

## Modo Escaneo Completo

OWASP ZAP permite un escaneo completo, para correr un contenedor que lo haga, genere un reporte del análisis y el contenedor se elimine cuando el proceso haya finalizado.

```sh
mkdir -p /var/containers/owasp-zaproxy/{opt/owasp-zaproxy/sesiones,zap/wrk}
chown 1001:0 -R /var/containers/owasp-zaproxy

docker run -itd --rm --name owasp-zaproxy \
    -h zap.example.com \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/owasp-zaproxy/opt/owasp-zaproxy/sesiones:/opt/owasp-zaproxy/sesiones:z \
    -v /var/containers/owasp-zaproxy/zap/wrk/:/zap/wrk/:z \
    -e TZ=America/Mexico_City \
    -e ZAP_FULL_SCAN=true \
    -e ZAP_FS_OPTIONS='-t https://target-domain.com -w testreport.md' \
    dockeregistry.amovildigitalops.com/atomic-rhel7-owasp-zap
```

Este ejemplo hará un escaneo completo al sitio *https://target-domain.com* y generará un reporte en markdown llamado *testreport.md* que está ubicado en el directorio */var/containers/owasp-zaproxy/zap/wrk/*.

**NOTA: La variable *ZAP_FS_OPTIONS* permite configurar el scan que se realizará, simplemente poner las opciones como en el ejemplo de arriba.**

Todas las opciones disponibles son las siguientes:

```sh
    -t target         target URL including the protocol, e.g. https://www.example.com
Options:
    -h                print this help message
    -c config_file    config file to use to INFO, IGNORE or FAIL warnings
    -u config_url     URL of config file to use to INFO, IGNORE or FAIL warnings
    -g gen_file       generate default config file(all rules set to WARN)
    -m mins           the number of minutes to spider for (defaults to no limit)
    -r report_html    file to write the full ZAP HTML report
    -w report_md      file to write the full ZAP Wiki(Markdown) report
    -x report_xml     file to write the full ZAP XML report
    -J report_json    file to write the full ZAP JSON document
    -a                include the alpha active and passive scan rules as well
    -d                show debug messages
    -P                specify listen port
    -D                delay in seconds to wait for passive scanning 
    -i                default rules not in the config file to INFO
    -j                use the Ajax spider in addition to the traditional one
    -l level          minimum level to show: PASS, IGNORE, INFO, WARN or FAIL, use with -s to hide example URLs
    -n context_file   context file which will be loaded prior to scanning the target
    -p progress_file  progress file which specifies issues that are being addressed
    -s                short output format - dont show PASSes or example URLs
    -T                max time in minutes to wait for ZAP to start and the passive scan to run
    -z zap_options    ZAP command line options e.g. -z "-config aaa=bbb -config ccc=ddd"
    --hook            path to python file that define your custom hooks

For more details see https://github.com/zaproxy/zaproxy/wiki/ZAP-Full-Scan
```
