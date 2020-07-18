# 3Scale (Despliegue a partir del yml para el despliegue en Openshift)

> **Este primer despliegue de 3scale no contempla autenticación con OpenID.**

**Nota:** El despliegue de esta herramienta en este ejemplo se hace en un mismo host, los únicos componentes en hosts distintos son los dos Apicast (Staging y Production). Ajustar los runit con exposición de puertos necesarios en caso de hacer un despliegue distinto.

## Prerequisitos

* Virtual Rhel7/CentOS7
* Docker 1.13.X

### Imágenes necesarias para despliegue de 3scale

* registry.redhat.io/3scale-amp2/system-rhel7:3scale2.7
* registry.redhat.io/3scale-amp2/zync-rhel7:3scale2.7
* registry.redhat.io/3scale-amp2/backend-rhel7:3scale2.7
* registry.redhat.io/3scale-amp2/memcached-rhel7:3scale2.7
* registry.redhat.io/3scale-amp2/apicast-gateway-rhel7:3scale2.7
* registry.redhat.io/3scale-amp2/memcached-rhel7:3scale2.7
* registry.redhat.io/rhscl/redis-32-rhel7:3.2
* registry.redhat.io/rhscl/mysql-57-rhel7:5.7
* registry.redhat.io/rhscl/postgresql-10-rhel7

## Desarrollo

```sh
### Variables usadas en el despliegue
IP_SERVER="10.23.142.134" # Ip del servidor donde estará alojado 3Scale, sin contar los Apicast.
CONFIG_INTERNAL_API_USER="amxga" # Nombre del usuario con el que 3Scale realizará las conexiones internas.
CONFIG_INTERNAL_API_PASSWORD="abcd1234" # Password del usuario para las conexiones internas de 3Scale.
MYSQL_USER="3scale" # Usuario de la base de datos de 3Scale.
MYSQL_PASSWORD="abcd1234" # Password de la base de datos de 3Scale.
MYSQL_DATABASE="3scale_database" # Nombre de la base de datos de 3Scale.
MYSQL_ROOT_PASSWORD="abcd1234" # Password del usuario root de la base de datos de 3Scale.
MESSAGE_BUS_REDIS_URL="redis://system-redis:6379/1" # Define el bus de mensajes de redis del sistema externo para conectarse. Por defecto, el mismo valor que SYSTEM_REDIS_URL pero con la base de datos lógica incrementada en 1 y el resultado aplicado mod 16.
REDIS_NAMESPACE="" # Define el namespace a usar en la bd de Redis. Vacío significa que no usará un namespace.
MESSAGE_BUS_REDIS_NAMESPACE="" # Define el namespace que usará el System's Message Bus Redis Database. Vacío significa que no usará un namespace.
ZYNC_DATABASE_PASSWORD="abcd1234" # Password del Postgres del componente Zync.
SECRET_KEY_BASE="abcd1234" # Secret key para aplicación System.
ZYNC_AUTHENTICATION_TOKEN="tokenzyncabcd1234" # Token utilizado por Zync para la comunicacion con 3Scale
APICAST_REGISTRY_URL="http://10.23.142.133:8090/policies" # En la Ip apuntamos a donde estará alojada el Apicast staging, sólo configurar la Ip, NO modificar la ruta y el puerto
THREESCALE_SUPERDOMAIN="san.gadt.amxdigital.net" # Dominio de 3Scale
MASTER_PASSWORD="abcd1234" # Password del usuario master de 3Scale
ADMIN_ACCESS_TOKEN="Iwae6tooz3ke" # Token utilizado para la conexion entre el Apicast y el System-provider
USER_PASSWORD="abcd1234" # Password del usuario admin de 3Scale
USER_EMAIL="admin@amxiniciativas.com" # Email del usuario admin de 3Scale
RECAPTCHA_PUBLIC_KEY="eZ1Tiu0ooz6p" # reCAPTCHA site key (Usado para protección a SPAM)
RECAPTCHA_PRIVATE_KEY="puuWo5Patamo" # reCAPTCHA secret key (Usado para protección a SPAM)
APICAST_BACKEND_ROOT_ENDPOINT="https://backend-3scale.${THREESCALE_SUPERDOMAIN}" # Domino del backend de 3Scale, (debe ser accesible por todos los componentes)
BACKEND_ROUTE=$APICAST_BACKEND_ROOT_ENDPOINT # Debe ser el mismo que APICAST_BACKEND_ROOT_ENDPOINT
APICAST_ACCESS_TOKEN="eeDah0jiliGu" # Read Only Access Token que utilizará el Apicast para descargar su configuración.
CONFIG_EVENTS_HOOK_SHARED_SECRET="abcd1234" # Secret interno para master.
MASTER_ACCESS_TOKEN="aexieBoh9ja4" # Token para la conexión entre el Apicast y el System-master
```

### IMPORTANTE
Exponer los siguientes dominios (master y 3scale-admin son las dos interfaces web).
##### master.${THREESCALE_SUPERDOMAIN} 
* Apuntar a ${IP_SERVER}:3002    
* User: master
* Pass: ${MASTER_PASSWORD}

##### 3scale-admin.${THREESCALE_SUPERDOMAIN}
* Apuntar a ${IP_SERVER}:3003  
* User: admin
* Pass: ${USER_PASSWORD}

##### backend-3scale.${THREESCALE_SUPERDOMAIN} 
* Apuntar a ${IP_SERVER}:3000


### Puertos necesarios para comunicación de 3scale
> Dependiendo el tipo de despliegue de 3scale y sus componentes será necesario o no abrir los puertos para permitir comunicación entre servicios.

Donde se hará el despliegue de 3Scale:
+ 6379 System-redis 
+ 7379 Backend-redis
+ 3000 Backend-listener
+ 3306 System-mysql
+ 11211 System-memcache
+ 9306 System-phinx
+ 5432 Zync-database
+ 8080 Zync
+ 9394 Zync-que
+ 3002 System-master
+ 3003 System-provider
+ 3001 System-developer

Donde se hará el despliegue de Apicast stanging:
+ 8090
+ 8080
+ 9421

Donde se hará el despliegue de Apicast production:
+ 8090
+ 8080
+ 9421

## Despliegue de contenedores

**NOTA:** Mantener los nombres en links para el correcto funcionamiento de la herramienta. Si se despliega en hosts distintos y se cambian los *--link* por *--add-host* mantener de igual manera los nombres aquí mostrados.

**NOTA:** Cuidar el tiempo de despliegue entre cada componente, en general con veinte segundos entre componente es más que necesario para que éstos inicien correctamente. Revisar logs de cada componente para garantizar su correcto levantamiento y arrranque de la herramienta.

Backend-redis
```sh
THREESCALE_COMPONENT="backend-redis"
mkdir -p /var/containers/3scale/${THREESCALE_COMPONENT}/etc/redis.d/
mkdir -p /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/redis/data
cat <<EOF > /var/containers/3scale/${THREESCALE_COMPONENT}/etc/redis.d/redis.conf
protected-mode no

port 7379

timeout 0
tcp-keepalive 300

daemonize no
supervised no

loglevel notice

databases 16

save 900 1
save 300 10
save 60 10000

stop-writes-on-bgsave-error yes

rdbcompression yes
rdbchecksum yes

dbfilename dump.rdb

slave-serve-stale-data yes
slave-read-only yes

repl-diskless-sync no
repl-disable-tcp-nodelay no

appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes

lua-time-limit 5000

activerehashing no

aof-rewrite-incremental-fsync yes
dir /var/lib/redis/data
EOF

chown 1001:0 -R /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/redis/data
chown 1001:0 -R /var/containers/3scale/${THREESCALE_COMPONENT}/etc/redis.d/
chmod 766 -R /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/redis/data

docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/redis/data:/var/lib/redis/data:z \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/etc/redis.d/:/etc/redis.d/:z \
    -e "TZ=America/Mexico_City" \
    registry.redhat.io/rhscl/redis-32-rhel7:3.2 /opt/rh/rh-redis32/root/usr/bin/redis-server /etc/redis.d/redis.conf --daemonize "no"

```
System-redis
```sh
THREESCALE_COMPONENT="system-redis"
mkdir -p /var/containers/3scale/${THREESCALE_COMPONENT}/etc/redis.d/
mkdir -p /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/redis/data
cat <<EOF > /var/containers/3scale/${THREESCALE_COMPONENT}/etc/redis.d/redis.conf
protected-mode no

port 6379

timeout 0
tcp-keepalive 300

daemonize no
supervised no

loglevel notice

databases 16

save 900 1
save 300 10
save 60 10000

stop-writes-on-bgsave-error yes

rdbcompression yes
rdbchecksum yes

dbfilename dump.rdb

slave-serve-stale-data yes
slave-read-only yes

repl-diskless-sync no
repl-disable-tcp-nodelay no

appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes

lua-time-limit 5000

activerehashing no

aof-rewrite-incremental-fsync yes
dir /var/lib/redis/data
EOF

chown 1001:0 -R /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/redis/data
chown 1001:0 -R /var/containers/3scale/${THREESCALE_COMPONENT}/etc/redis.d/
chmod 766 -R /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/redis/data

docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/redis/data:/var/lib/redis/data:z \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/etc/redis.d/:/etc/redis.d/:z \
    -e "TZ=America/Mexico_City" \
    registry.redhat.io/rhscl/redis-32-rhel7:3.2 /opt/rh/rh-redis32/root/usr/bin/redis-server /etc/redis.d/redis.conf --daemonize "no"
```
Backend Cron
```sh
THREESCALE_COMPONENT="backend-cron"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "CONFIG_REDIS_PROXY=redis://backend-redis:7379/0" \
    -e "CONFIG_QUEUES_MASTER_NAME=redis://backend-redis:7379/1" \
    -e "RACK_ENV=production" \
    -e "SLEEP_SECONDS=1" \
    --link 3scale.backend-redis:backend-redis \
    registry.redhat.io/3scale-amp2/backend-rhel7:3scale2.7 backend-cron
```
Backend-listener
```sh
THREESCALE_COMPONENT="backend-listener"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "CONFIG_REDIS_PROXY=redis://backend-redis:7379/0" \
    -e "CONFIG_QUEUES_MASTER_NAME=redis://backend-redis:7379/1" \
    -e "RACK_ENV=production" \
    -e "PUMA_WORKERS=16" \
    -e "CONFIG_INTERNAL_API_USER=$CONFIG_INTERNAL_API_USER" \
    -e "CONFIG_INTERNAL_API_PASSWORD=$CONFIG_INTERNAL_API_PASSWORD" \
    -p 3000:3000 \
    --link 3scale.backend-redis:backend-redis \
    registry.redhat.io/3scale-amp2/backend-rhel7:3scale2.7 bin/3scale_backend start -e production -p "3000" -x /dev/stdout
```
System-mysql
```sh
THREESCALE_COMPONENT="system-mysql"
mkdir -p /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/mysql/data
mkdir -p /var/containers/3scale/${THREESCALE_COMPONENT}/etc/my-extra.d
mkdir -p /var/containers/3scale/${THREESCALE_COMPONENT}/etc/my-extra

cat <<EOF > /var/containers/3scale/${THREESCALE_COMPONENT}/etc/my-extra.d/mysql-charset.cnf
[client]
default-character-set = utf8

[mysql]
default-character-set = utf8

[mysqld]
character-set-server = utf8
collation-server = utf8_unicode_ci
EOF

cat <<EOF > /var/containers/3scale/${THREESCALE_COMPONENT}/etc/my-extra/my.cnf
!include /etc/my.cnf
!includedir /etc/my-extra.d
EOF

chown 27:0 -R /var/containers/3scale/${THREESCALE_COMPONENT}/

docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/mysql/data:/var/lib/mysql/data:z \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/etc/my-extra.d:/etc/my-extra.d:z \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/etc/my-extra:/etc/my-extra:z \
    -e "TZ=America/Mexico_City" \
    -e "MYSQL_USER=$MYSQL_USER" \
    -e "MYSQL_PASSWORD=$MYSQL_PASSWORD" \
    -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
    -e "MYSQL_LOWER_CASE_TABLE_NAMES=1" \
    -e "MYSQL_DEFAULTS_FILE=/etc/my-extra/my.cnf" \
    registry.redhat.io/rhscl/mysql-57-rhel7:5.7
```
System-memcache
```sh
THREESCALE_COMPONENT="system-memcache"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    registry.redhat.io/3scale-amp2/memcached-rhel7:3scale2.7 memcached -m "64"
```
System-prepare-database
```sh
THREESCALE_COMPONENT="system-prepare-database"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "AMP_RELEASE=2.7" \
    -e "APICAST_REGISTRY_URL=$APICAST_REGISTRY_URL" \
    -e "FORCE_SSL=false" \
    -e "PROVIDER_PLAN=enterprise" \
    -e "RAILS_ENV=production" \
    -e "RAILS_LOG_LEVEL=info" \
    -e "RAILS_LOG_TO_STDOUT=true" \
    -e "THINKING_SPHINX_PORT=9306" \
    -e "THREESCALE_SANDBOX_PROXY_OPENSSL_VERIFY_MODE=VERIFY_NONE" \
    -e "THREESCALE_SUPERDOMAIN=$THREESCALE_SUPERDOMAIN" \
    -e "DATABASE_URL=mysql2://${MYSQL_USER}:${MYSQL_PASSWORD}@system-mysql/${MYSQL_DATABASE}" \
    -e "MASTER_DOMAIN=master" \
    -e "MASTER_USER=master" \
    -e "MASTER_PASSWORD=$MASTER_PASSWORD" \
    -e "ADMIN_ACCESS_TOKEN=$ADMIN_ACCESS_TOKEN" \
    -e "USER_LOGIN=admin" \
    -e "USER_PASSWORD=$USER_PASSWORD" \
    -e "USER_EMAIL=$USER_EMAIL" \
    -e "TENANT_NAME=3scale" \
    -e "THINKING_SPHINX_ADDRESS=system-sphinx" \
    -e "THINKING_SPHINX_CONFIGURATION_FILE=/tmp/sphinx.conf" \
    -e "EVENTS_SHARED_SECRET=$CONFIG_EVENTS_HOOK_SHARED_SECRET" \
    -e "RECAPTCHA_PUBLIC_KEY=$RECAPTCHA_PUBLIC_KEY" \
    -e "RECAPTCHA_PRIVATE_KEY=$RECAPTCHA_PRIVATE_KEY" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -e "MEMCACHE_SERVERS=system-memcache:11211" \
    -e "REDIS_URL=redis://system-redis:6379/1" \
    -e "MESSAGE_BUS_REDIS_URL=$MESSAGE_BUS_REDIS_URL" \
    -e "REDIS_NAMESPACE=$REDIS_NAMESPACE" \
    -e "MESSAGE_BUS_REDIS_NAMESPACE=$MESSAGE_BUS_REDIS_NAMESPACE" \
    -e "BACKEND_REDIS_URL=redis://backend-redis:7379/0" \
    -e "APICAST_BACKEND_ROOT_ENDPOINT=$APICAST_BACKEND_ROOT_ENDPOINT" \
    -e "BACKEND_ROUTE=$BACKEND_ROUTE" \
    -e "APICAST_ACCESS_TOKEN=$APICAST_ACCESS_TOKEN" \
    -e "ZYNC_AUTHENTICATION_TOKEN=$ZYNC_AUTHENTICATION_TOKEN" \
    -e "CONFIG_INTERNAL_API_USER=$CONFIG_INTERNAL_API_USER" \
    -e "CONFIG_INTERNAL_API_PASSWORD=$CONFIG_INTERNAL_API_PASSWORD" \
    -e "MASTER_ACCESS_TOKEN=$MASTER_ACCESS_TOKEN" \
    --link 3scale.system-mysql:system-mysql \
    --link 3scale.system-memcache:system-memcache \
    --link 3scale.system-redis:system-redis \
    --link 3scale.backend-redis:backend-redis \
    --link 3scale.backend-listener:backend-listener \
    registry.redhat.io/3scale-amp2/system-rhel7:3scale2.7 bash -c 'bundle exec rake boot openshift:deploy MASTER_ACCESS_TOKEN="${MASTER_ACCESS_TOKEN}" && bundle exec rake services:create_backend_apis services:update_metric_owners proxy:update_proxy_rule_owners'
```
**Esperar al menos 30 segundos para que este contenedor termine su tarea. Verificar en logs.**

Salida ejemplo de este componente: 
```sh
# ===========================================================================
# Setup Completed

# Root Domain: san.gadt.amxdigital.net

# Master Domain: master.san.gadt.amxdigital.net
# Master User Login: master
# Master User Password: abcd1234
# Master RW access token: aexieBoh9ja4

# Provider Admin Domain: 3scale-admin.san.gadt.amxdigital.net
# Provider Portal Domain: 3scale.san.gadt.amxdigital.net
# Provider User Login: admin
# Provider User Password: abcd1234
# APIcast Access Token: eeDah0jiliGu
# Admin Access Token: Iwae6tooz3ke
# ===========================================================================
```
System-sphinx
```sh
THREESCALE_COMPONENT="system-sphinx"
mkdir -p /var/containers/3scale/${THREESCALE_COMPONENT}/opt/system/db/sphinx
chown 1001:0 -R /var/containers/3scale/${THREESCALE_COMPONENT}/opt/system/db/sphinx
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/opt/system/db/sphinx:/opt/system/db/sphinx:z \
    -e "TZ=America/Mexico_City" \
    -e "AMP_RELEASE=2.7" \
    -e "APICAST_REGISTRY_URL=$APICAST_REGISTRY_URL" \
    -e "FORCE_SSL=false" \
    -e "PROVIDER_PLAN=enterprise" \
    -e "RAILS_ENV=production" \
    -e "RAILS_LOG_LEVEL=info" \
    -e "RAILS_LOG_TO_STDOUT=true" \
    -e "THINKING_SPHINX_PORT=9306" \
    -e "THREESCALE_SANDBOX_PROXY_OPENSSL_VERIFY_MODE=VERIFY_NONE" \
    -e "THREESCALE_SUPERDOMAIN=$THREESCALE_SUPERDOMAIN" \
    -e "DATABASE_URL=mysql2://${MYSQL_USER}:${MYSQL_PASSWORD}@system-mysql/${MYSQL_DATABASE}" \
    -e "THINKING_SPHINX_ADDRESS=0.0.0.0" \
    -e "THINKING_SPHINX_CONFIGURATION_FILE=db/sphinx/production.conf" \
    -e "THINKING_SPHINX_PID_FILE=db/sphinx/searchd.pid" \
    -e "DELTA_INDEX_INTERVAL=5" \
    -e "FULL_REINDEX_INTERVAL=60" \
    -e "REDIS_URL=redis://system-redis:6379/1" \
    -e "MESSAGE_BUS_REDIS_URL=$MESSAGE_BUS_REDIS_URL" \
    -e "REDIS_NAMESPACE=$REDIS_NAMESPACE" \
    -e "MESSAGE_BUS_REDIS_NAMESPACE=$MESSAGE_BUS_REDIS_NAMESPACE" \
    --link 3scale.system-mysql:system-mysql \
    --link 3scale.system-mysql:system-mysql \
    --link 3scale.system-redis:system-redis \
    --link 3scale.backend-redis:backend-redis \
    --link 3scale.backend-listener:backend-listener \
    --link 3scale.system-memcache:system-memcache \
    registry.redhat.io/3scale-amp2/system-rhel7:3scale2.7 rake openshift:thinking_sphinx:start
```
Zync-database
```sh
THREESCALE_COMPONENT="zync-database"
mkdir -p /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/pgsql/data
chown 26:0 -R /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/pgsql/data
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/var/lib/pgsql/data:/var/lib/pgsql/data:z \
    -e "TZ=America/Mexico_City" \
    -e "POSTGRESQL_USER=zync" \
    -e "POSTGRESQL_PASSWORD=$ZYNC_DATABASE_PASSWORD" \
    -e "POSTGRESQL_DATABASE=zync_production" \
    registry.redhat.io/rhscl/postgresql-10-rhel7
```
Zync
```sh
THREESCALE_COMPONENT="zync"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/${THREESCALE_COMPONENT}/opt/system/db/sphinx:/opt/system/db/sphinx:z \
    -e "TZ=America/Mexico_City" \
    -e "RAILS_LOG_TO_STDOUT=true" \
    -e "RAILS_ENV=production" \
    -e "FORCE_SSL=false" \
    -e "DATABASE_URL=postgresql://zync:${ZYNC_DATABASE_PASSWORD}@zync-database:5432/zync_production" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -e "ZYNC_AUTHENTICATION_TOKEN=$ZYNC_AUTHENTICATION_TOKEN" \
    --link 3scale.zync-database:zync-database \
    registry.redhat.io/3scale-amp2/zync-rhel7:3scale2.7
```
Zync-que
```sh
THREESCALE_COMPONENT="zync-que"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "RAILS_LOG_TO_STDOUT=true" \
    -e "RAILS_ENV=production" \
    -e "FORCE_SSL=false" \
    -e "DATABASE_URL=postgresql://zync:${ZYNC_DATABASE_PASSWORD}@zync-database:5432/zync_production" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -e "ZYNC_AUTHENTICATION_TOKEN=$ZYNC_AUTHENTICATION_TOKEN" \
    --link 3scale.zync-database:zync-database \
    registry.redhat.io/3scale-amp2/zync-rhel7:3scale2.7 /usr/bin/bash -c "bundle exec rake 'que[--worker-count 10]'"
```
System-master
```sh
mkdir -p /var/containers/3scale/system/opt/system/public/system
mkdir -p /var/containers/3scale/system/opt/system-extra-configs
mkdir -p /var/containers/3scale/system/opt/system/config/

cat <<EOF > /var/containers/3scale/system/opt/system-extra-configs/zync.yml
production:
    endpoint: 'http://zync:8080'
    authentication:
        token: "<%= ENV.fetch('ZYNC_AUTHENTICATION_TOKEN') %>"
    connect_timeout: 5
    send_timeout: 5
    receive_timeout: 10
    root_url:
EOF

cat <<EOF > /var/containers/3scale/system/opt/system/config/settings.yml
base: &default
  superdomain: <%= superdomain = ENV.fetch('THREESCALE_SUPERDOMAIN', 'example.com') %>
  apicast_internal_host_regexp: '\Asystem-(master|provider|developer)\Z'
  secure_cookie: true
  force_ssl: false
  apicast_oauth: true
  apicast_custom_url: true
  apicast_configuration_driven: true
  active_docs_url:
  active_docs_proxy_disabled: true
  asset_host: <%= ENV.fetch('RAILS_ASSET_HOST', nil) %>
  events_shared_secret: <%= ENV['EVENTS_SHARED_SECRET'] %>
  onpremises_api_docs_version: true
  onpremises: true
  recaptcha_public_key: <%= ENV.fetch('RECAPTCHA_PUBLIC_KEY', 'YOUR_RECAPTCHA_PUBLIC_KEY') %>
  recaptcha_private_key: <%= ENV['RECAPTCHA_PRIVATE_KEY'] %>

  # System Emails
  noreply_email: <%= ENV.fetch('NOREPLY_EMAIL', "no-reply@#{superdomain}") %>
  support_email: <%= ENV.fetch('SUPPORT_EMAIL', "#{superdomain} Support <support@#{superdomain}>") %>
  sales_email: <%= ENV.fetch('SALES_EMAIL', "sales@#{superdomain}") %>
  notification_email: <%= ENV.fetch('NOTIFICATION_EMAIL', "#{superdomain} Notification <no-reply@#{superdomain}>") %>
  golive_email: <%= ENV.fetch('GOLIVE_EMAIL', "golive@#{superdomain}") %>
  sysadmin_email: <%= ENV.fetch('SYSADMIN_EMAIL', "sysadmin@#{superdomain}") %>
  impersonation_admin:
    username: <%= ENV.fetch('IMPERSONATION_ADMIN_USERNAME', '3scaleadmin') %>
    domain: <%= ENV.fetch('IMPERSONATION_ADMIN_DOMAIN', '3scale.net') %>

  readonly_custom_domains_settings: false
  report_traffic: false
  hide_basic_switches: true
  tenant_mode: <%= ENV['TENANT_MODE'] %>
  db_secret:

  assets_cdn_host: <%= ENV.fetch('ASSETS_CDN_HOST', '') %>
  zync_authentication_token: <%= ENV.fetch('ZYNC_AUTHENTICATON_TOKEN', '') %>

  email_sanitizer:
    enabled: <%= ENV.fetch('EMAIL_SANITIZER_ENABLED', Rails.env.preview?) %>
    to: <%= ENV.fetch('EMAIL_SANITIZER_TO', 'sanitizer@example.com') %>

  active_merchant_logging: false
  billing_canaries:

preview:
  <<: *default

production:
  <<: *default
EOF

chown 1001:0 -R /var/containers/3scale/system

THREESCALE_COMPONENT="system-master"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/system/opt/system/public/system:/opt/system/public/system:z \
    -v /var/containers/3scale/system/opt/system-extra-configs:/opt/system-extra-configs:z \
    -v /var/containers/3scale/system/opt/system/config/settings.yml:/opt/system/config/settings.yml:ro \
    -e "TZ=America/Mexico_City" \
    -e "AMP_RELEASE=2.7" \
    -e "APICAST_REGISTRY_URL=$APICAST_REGISTRY_URL" \
    -e "FORCE_SSL=false" \
    -e "PROVIDER_PLAN=enterprise" \
    -e "RAILS_ENV=production" \
    -e "RAILS_LOG_LEVEL=info" \
    -e "RAILS_LOG_TO_STDOUT=true" \
    -e "THINKING_SPHINX_PORT=9306" \
    -e "THREESCALE_SANDBOX_PROXY_OPENSSL_VERIFY_MODE=VERIFY_NONE" \
    -e "THREESCALE_SUPERDOMAIN=$THREESCALE_SUPERDOMAIN" \
    -e "DATABASE_URL=mysql2://${MYSQL_USER}:${MYSQL_PASSWORD}@system-mysql/${MYSQL_DATABASE}" \
    -e "MASTER_DOMAIN=master" \
    -e "MASTER_USER=master" \
    -e "MASTER_PASSWORD=$MASTER_PASSWORD" \
    -e "ADMIN_ACCESS_TOKEN=$ADMIN_ACCESS_TOKEN" \
    -e "USER_LOGIN=admin" \
    -e "USER_PASSWORD=$USER_PASSWORD" \
    -e "USER_EMAIL=$USER_EMAIL" \
    -e "TENANT_NAME=3scale" \
    -e "THINKING_SPHINX_ADDRESS=system-sphinx" \
    -e "THINKING_SPHINX_CONFIGURATION_FILE=/tmp/sphinx.conf" \
    -e "EVENTS_SHARED_SECRET=$CONFIG_EVENTS_HOOK_SHARED_SECRET" \
    -e "RECAPTCHA_PUBLIC_KEY=$RECAPTCHA_PUBLIC_KEY" \
    -e "RECAPTCHA_PRIVATE_KEY=$RECAPTCHA_PRIVATE_KEY" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -e "MEMCACHE_SERVERS=system-memcache:11211" \
    -e "REDIS_URL=redis://system-redis:6379/1" \
    -e "MESSAGE_BUS_REDIS_URL=$MESSAGE_BUS_REDIS_URL" \
    -e "REDIS_NAMESPACE=$REDIS_NAMESPACE" \
    -e "MESSAGE_BUS_REDIS_NAMESPACE=$MESSAGE_BUS_REDIS_NAMESPACE" \
    -e "BACKEND_REDIS_URL=redis://backend-redis:7379/0" \
    -e "APICAST_BACKEND_ROOT_ENDPOINT=$APICAST_BACKEND_ROOT_ENDPOINT" \
    -e "BACKEND_ROUTE=$BACKEND_ROUTE" \
    -e "APICAST_ACCESS_TOKEN=$APICAST_ACCESS_TOKEN" \
    -e "ZYNC_AUTHENTICATION_TOKEN=$ZYNC_AUTHENTICATION_TOKEN" \
    -e "CONFIG_INTERNAL_API_USER=$CONFIG_INTERNAL_API_USER" \
    -e "CONFIG_INTERNAL_API_PASSWORD=$CONFIG_INTERNAL_API_PASSWORD" \
    -e "MASTER_ACCESS_TOKEN=$MASTER_ACCESS_TOKEN" \
    -p 3002:3002 \
    --link 3scale.system-mysql:system-mysql \
    --link 3scale.system-redis:system-redis \
    --link 3scale.backend-redis:backend-redis \
    --link 3scale.backend-listener:backend-listener \
    --link 3scale.system-memcache:system-memcache \
    --link 3scale.system-sphinx:system-sphinx \
    --link 3scale.zync:zync \
    registry.redhat.io/3scale-amp2/system-rhel7:3scale2.7 env TENANT_MODE=master PORT=3002 container-entrypoint bundle exec unicorn -c config/unicorn.rb
```
System-provider
```sh
THREESCALE_COMPONENT="system-provider"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/system/opt/system/public/system:/opt/system/public/system:z \
    -v /var/containers/3scale/system/opt/system-extra-configs:/opt/system-extra-configs:z \
    -e "TZ=America/Mexico_City" \
    -e "AMP_RELEASE=2.7" \
    -e "APICAST_REGISTRY_URL=$APICAST_REGISTRY_URL" \
    -e "FORCE_SSL=false" \
    -e "PROVIDER_PLAN=enterprise" \
    -e "RAILS_ENV=production" \
    -e "RAILS_LOG_LEVEL=info" \
    -e "RAILS_LOG_TO_STDOUT=true" \
    -e "THINKING_SPHINX_PORT=9306" \
    -e "THREESCALE_SANDBOX_PROXY_OPENSSL_VERIFY_MODE=VERIFY_NONE" \
    -e "THREESCALE_SUPERDOMAIN=$THREESCALE_SUPERDOMAIN" \
    -e "DATABASE_URL=mysql2://${MYSQL_USER}:${MYSQL_PASSWORD}@system-mysql/${MYSQL_DATABASE}" \
    -e "MASTER_DOMAIN=master" \
    -e "MASTER_USER=master" \
    -e "MASTER_PASSWORD=$MASTER_PASSWORD" \
    -e "ADMIN_ACCESS_TOKEN=$ADMIN_ACCESS_TOKEN" \
    -e "USER_LOGIN=admin" \
    -e "USER_PASSWORD=$USER_PASSWORD" \
    -e "USER_EMAIL=$USER_EMAIL" \
    -e "TENANT_NAME=3scale" \
    -e "THINKING_SPHINX_ADDRESS=system-sphinx" \
    -e "THINKING_SPHINX_CONFIGURATION_FILE=/tmp/sphinx.conf" \
    -e "EVENTS_SHARED_SECRET=$CONFIG_EVENTS_HOOK_SHARED_SECRET" \
    -e "RECAPTCHA_PUBLIC_KEY=$RECAPTCHA_PUBLIC_KEY" \
    -e "RECAPTCHA_PRIVATE_KEY=$RECAPTCHA_PRIVATE_KEY" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -e "MEMCACHE_SERVERS=system-memcache:11211" \
    -e "REDIS_URL=redis://system-redis:6379/1" \
    -e "MESSAGE_BUS_REDIS_URL=$MESSAGE_BUS_REDIS_URL" \
    -e "REDIS_NAMESPACE=$REDIS_NAMESPACE" \
    -e "MESSAGE_BUS_REDIS_NAMESPACE=$MESSAGE_BUS_REDIS_NAMESPACE" \
    -e "BACKEND_REDIS_URL=redis://backend-redis:7379/0" \
    -e "APICAST_BACKEND_ROOT_ENDPOINT=$APICAST_BACKEND_ROOT_ENDPOINT" \
    -e "BACKEND_ROUTE=$BACKEND_ROUTE" \
    -e "APICAST_ACCESS_TOKEN=$APICAST_ACCESS_TOKEN" \
    -e "ZYNC_AUTHENTICATION_TOKEN=$ZYNC_AUTHENTICATION_TOKEN" \
    -e "CONFIG_INTERNAL_API_USER=$CONFIG_INTERNAL_API_USER" \
    -e "CONFIG_INTERNAL_API_PASSWORD=$CONFIG_INTERNAL_API_PASSWORD" \
    -e "MASTER_ACCESS_TOKEN=$MASTER_ACCESS_TOKEN" \
    -p 3003:3003 \
    --link 3scale.system-mysql:system-mysql \
    --link 3scale.system-redis:system-redis \
    --link 3scale.backend-redis:backend-redis \
    --link 3scale.backend-listener:backend-listener \
    --link 3scale.system-memcache:system-memcache \
    --link 3scale.system-sphinx:system-sphinx \
    --link 3scale.zync:zync \
    registry.redhat.io/3scale-amp2/system-rhel7:3scale2.7 env TENANT_MODE=provider PORT=3003 container-entrypoint bundle exec unicorn -c config/unicorn.rb
```
System-developer
```sh
THREESCALE_COMPONENT="system-developer"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    --restart always \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/system/opt/system/public/system:/opt/system/public/system:z \
    -v /var/containers/3scale/system/opt/system-extra-configs:/opt/system-extra-configs:z \
    -e "TZ=America/Mexico_City" \
    -e "AMP_RELEASE=2.7" \
    -e "APICAST_REGISTRY_URL=$APICAST_REGISTRY_URL" \
    -e "FORCE_SSL=false" \
    -e "PROVIDER_PLAN=enterprise" \
    -e "RAILS_ENV=production" \
    -e "RAILS_LOG_LEVEL=info" \
    -e "RAILS_LOG_TO_STDOUT=true" \
    -e "THINKING_SPHINX_PORT=9306" \
    -e "THREESCALE_SANDBOX_PROXY_OPENSSL_VERIFY_MODE=VERIFY_NONE" \
    -e "THREESCALE_SUPERDOMAIN=$THREESCALE_SUPERDOMAIN" \
    -e "DATABASE_URL=mysql2://${MYSQL_USER}:${MYSQL_PASSWORD}@system-mysql/${MYSQL_DATABASE}" \
    -e "MASTER_DOMAIN=master" \
    -e "MASTER_USER=master" \
    -e "MASTER_PASSWORD=$MASTER_PASSWORD" \
    -e "ADMIN_ACCESS_TOKEN=$ADMIN_ACCESS_TOKEN" \
    -e "USER_LOGIN=admin" \
    -e "USER_PASSWORD=$USER_PASSWORD" \
    -e "USER_EMAIL=$USER_EMAIL" \
    -e "TENANT_NAME=3scale" \
    -e "THINKING_SPHINX_ADDRESS=system-sphinx" \
    -e "THINKING_SPHINX_CONFIGURATION_FILE=/tmp/sphinx.conf" \
    -e "EVENTS_SHARED_SECRET=$CONFIG_EVENTS_HOOK_SHARED_SECRET" \
    -e "RECAPTCHA_PUBLIC_KEY=$RECAPTCHA_PUBLIC_KEY" \
    -e "RECAPTCHA_PRIVATE_KEY=$RECAPTCHA_PRIVATE_KEY" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -e "MEMCACHE_SERVERS=system-memcache:11211" \
    -e "REDIS_URL=redis://system-redis:6379/1" \
    -e "MESSAGE_BUS_REDIS_URL=$MESSAGE_BUS_REDIS_URL" \
    -e "REDIS_NAMESPACE=$REDIS_NAMESPACE" \
    -e "MESSAGE_BUS_REDIS_NAMESPACE=$MESSAGE_BUS_REDIS_NAMESPACE" \
    -e "BACKEND_REDIS_URL=redis://backend-redis:7379/0" \
    -e "APICAST_BACKEND_ROOT_ENDPOINT=$APICAST_BACKEND_ROOT_ENDPOINT" \
    -e "BACKEND_ROUTE=$BACKEND_ROUTE" \
    -e "APICAST_ACCESS_TOKEN=$APICAST_ACCESS_TOKEN" \
    -e "ZYNC_AUTHENTICATION_TOKEN=$ZYNC_AUTHENTICATION_TOKEN" \
    -e "CONFIG_INTERNAL_API_USER=$CONFIG_INTERNAL_API_USER" \
    -e "CONFIG_INTERNAL_API_PASSWORD=$CONFIG_INTERNAL_API_PASSWORD" \
    -e "MASTER_ACCESS_TOKEN=$MASTER_ACCESS_TOKEN" \
    -p 3001:3001 \
    --link 3scale.system-mysql:system-mysql \
    --link 3scale.system-redis:system-redis \
    --link 3scale.backend-redis:backend-redis \
    --link 3scale.backend-listener:backend-listener \
    --link 3scale.system-memcache:system-memcache \
    --link 3scale.system-sphinx:system-sphinx \
    --link 3scale.zync:zync \
    registry.redhat.io/3scale-amp2/system-rhel7:3scale2.7 env PORT=3001 container-entrypoint bundle exec unicorn -c config/unicorn.rb
```
System-sidekiq
```sh
THREESCALE_COMPONENT="system-sidekiq"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/3scale/system/opt/system/public/system:/opt/system/public/system:z \
    -v /var/containers/3scale/system/opt/system-extra-configs:/opt/system-extra-configs:z \
    -e "TZ=America/Mexico_City" \
    -e "AMP_RELEASE=2.7" \
    -e "APICAST_REGISTRY_URL=$APICAST_REGISTRY_URL" \
    -e "FORCE_SSL=false" \
    -e "PROVIDER_PLAN=enterprise" \
    -e "RAILS_ENV=production" \
    -e "RAILS_LOG_LEVEL=info" \
    -e "RAILS_LOG_TO_STDOUT=true" \
    -e "THINKING_SPHINX_PORT=9306" \
    -e "THREESCALE_SANDBOX_PROXY_OPENSSL_VERIFY_MODE=VERIFY_NONE" \
    -e "THREESCALE_SUPERDOMAIN=$THREESCALE_SUPERDOMAIN" \
    -e "DATABASE_URL=mysql2://${MYSQL_USER}:${MYSQL_PASSWORD}@system-mysql/${MYSQL_DATABASE}" \
    -e "MASTER_DOMAIN=master" \
    -e "MASTER_USER=master" \
    -e "MASTER_PASSWORD=$MASTER_PASSWORD" \
    -e "ADMIN_ACCESS_TOKEN=$ADMIN_ACCESS_TOKEN" \
    -e "USER_LOGIN=admin" \
    -e "USER_PASSWORD=$USER_PASSWORD" \
    -e "USER_EMAIL=$USER_EMAIL" \
    -e "TENANT_NAME=3scale" \
    -e "THINKING_SPHINX_ADDRESS=system-sphinx" \
    -e "THINKING_SPHINX_CONFIGURATION_FILE=/tmp/sphinx.conf" \
    -e "EVENTS_SHARED_SECRET=$CONFIG_EVENTS_HOOK_SHARED_SECRET" \
    -e "RECAPTCHA_PUBLIC_KEY=$RECAPTCHA_PUBLIC_KEY" \
    -e "RECAPTCHA_PRIVATE_KEY=$RECAPTCHA_PRIVATE_KEY" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -e "MEMCACHE_SERVERS=system-memcache:11211" \
    -e "REDIS_URL=redis://system-redis:6379/1" \
    -e "MESSAGE_BUS_REDIS_URL=$MESSAGE_BUS_REDIS_URL" \
    -e "REDIS_NAMESPACE=$REDIS_NAMESPACE" \
    -e "MESSAGE_BUS_REDIS_NAMESPACE=$MESSAGE_BUS_REDIS_NAMESPACE" \
    -e "BACKEND_REDIS_URL=redis://backend-redis:7379/0" \
    -e "APICAST_BACKEND_ROOT_ENDPOINT=$APICAST_BACKEND_ROOT_ENDPOINT" \
    -e "BACKEND_ROUTE=$BACKEND_ROUTE" \
    -e "APICAST_ACCESS_TOKEN=$APICAST_ACCESS_TOKEN" \
    -e "ZYNC_AUTHENTICATION_TOKEN=$ZYNC_AUTHENTICATION_TOKEN" \
    -e "CONFIG_INTERNAL_API_USER=$CONFIG_INTERNAL_API_USER" \
    -e "CONFIG_INTERNAL_API_PASSWORD=$CONFIG_INTERNAL_API_PASSWORD" \
    --link 3scale.system-mysql:system-mysql \
    --link 3scale.system-sphinx:system-sphinx \
    --link 3scale.system-memcache:system-memcache \
    --link 3scale.system-redis:system-redis \
    --link 3scale.backend-redis:backend-redis \
    --link 3scale.backend-listener:backend-listener \
    --link 3scale.zync:zync \
    registry.redhat.io/3scale-amp2/system-rhel7:3scale2.7 rake sidekiq:worker RAILS_MAX_THREADS=25
```
Backend-worker
```sh
THREESCALE_COMPONENT="backend-worker"
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "CONFIG_REDIS_PROXY=redis://backend-redis:7379/0" \
    -e "CONFIG_QUEUES_MASTER_NAME=redis://backend-redis:7379/1" \
    -e "RACK_ENV=production" \
    -e "FORCE_SSL=false" \
    -e "CONFIG_EVENTS_HOOK=http://system-master:3002/master/events/import" \
    -e "CONFIG_EVENTS_HOOK_SHARED_SECRET=$CONFIG_EVENTS_HOOK_SHARED_SECRET" \
    --link 3scale.backend-redis:backend-redis \
    --link 3scale.system-master:system-master \
    --link 3scale.system-mysql:system-mysql \
    --link 3scale.system-sphinx:system-sphinx \
    --link 3scale.system-memcache:system-memcache \
    --link 3scale.system-redis:system-redis \
    --link 3scale.backend-redis:backend-redis \
    --link 3scale.backend-listener:backend-listener \
    registry.redhat.io/3scale-amp2/backend-rhel7:3scale2.7 bin/3scale_backend_worker run
```
## Despliegue de Apicast
En hosts independientes se despliega cada Apicast.

Apicast-staging
```sh
THREESCALE_COMPONENT="apicast-staging"
APICAST_ACCESS_TOKEN="aexieBoh9ja4" # Debe ser el mismo que MASTER_ACCESS_TOKEN
THREESCALE_SYSTEM_MASTER_IP="10.23.142.134" # Apuntamos a donde está alojado system-master == IP_SERVER
BACKEND_ENDPOINT_OVERRIDE=$THREESCALE_SYSTEM_MASTER_IP
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "THREESCALE_PORTAL_ENDPOINT=http://${APICAST_ACCESS_TOKEN}@${THREESCALE_SYSTEM_MASTER_IP}:3002/master/api/proxy/configs" \
    -e "BACKEND_ENDPOINT_OVERRIDE=http://${BACKEND_ENDPOINT_OVERRIDE}:3000" \
    -e "APICAST_MANAGEMENT_API=status" \
    -e "OPENSSL_VERIFY=false" \
    -e "APICAST_RESPONSE_CODES=true" \
    -e "APICAST_CONFIGURATION_LOADER=lazy" \
    -e "APICAST_CONFIGURATION_CACHE=0" \
    -e "THREESCALE_DEPLOYMENT_ENV=staging" \
    -e "APICAST_PATH_ROUTING=false" \
    -p 8090:8090 \
    -p 8080:8080 \
    -p 9421:9421 \
    registry.redhat.io/3scale-amp2/apicast-gateway-rhel7:3scale2.7
```
Apicast-production
```sh
THREESCALE_COMPONENT="apicast-production"
APICAST_ACCESS_TOKEN="aexieBoh9ja4" # Debe ser el mismo que MASTER_ACCESS_TOKEN
THREESCALE_SYSTEM_MASTER_IP="10.23.142.134" # Apuntamos a donde esta alojado system-master == API_SERVER
BACKEND_ENDPOINT_OVERRIDE=$THREESCALE_SYSTEM_MASTER_IP
docker run -itd --name 3scale.${THREESCALE_COMPONENT} \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=America/Mexico_City" \
    -e "THREESCALE_PORTAL_ENDPOINT=http://${APICAST_ACCESS_TOKEN}@${THREESCALE_SYSTEM_MASTER_IP}:3002/master/api/proxy/configs" \
    -e "BACKEND_ENDPOINT_OVERRIDE=http://${BACKEND_ENDPOINT_OVERRIDE}:3000" \
    -e "APICAST_MANAGEMENT_API=status" \
    -e "OPENSSL_VERIFY=false" \
    -e "APICAST_RESPONSE_CODES=true" \
    -e "APICAST_CONFIGURATION_LOADER=boot" \
    -e "APICAST_CONFIGURATION_CACHE=50" \
    -e "THREESCALE_DEPLOYMENT_ENV=production" \
    -p 8080:8080 \
    -p 8090:8090 \
    -p 9421:9421 \
    registry.redhat.io/3scale-amp2/apicast-gateway-rhel7:3scale2.7
```

**NOTA:** Al exponer las apis detrás de un Nginx debe hacerse el proxy pass al apicast necesario, staging o production, por el puerto 8080.