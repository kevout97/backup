# Webshere Portal 9

## Prerequisitos

* Imagen docker hcl/dx/core:v95_20190928-2258
* Permitir tráfico en el puerto 10041
   
## Desarrollo

Para el despliegue de Webshere Portal 9 nos apoyamos del siguiente runit.

```bash
#!/bin/bash

##############################################
#                                            #
#               Webshere Portal 9            #
#                                            #
##############################################

WEBSHERE_CONTAINER="websehere.portal.9"
mkdir -p /var/containers/$WEBSHERE_CONTAINER/opt/HCL/wp_profile
chown 1000:0 -R /var/containers/$WEBSHERE_CONTAINER/opt/HCL/wp_profile

## Prepare volume
docker run -itd --name $WEBSHERE_CONTAINER \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/$WEBSHERE_CONTAINER/opt/HCL/wp_profile:/opt/HCL/wp_profile:z \
    -e TZ=America/Mexico_City \
    -p 10039:10039 \
    -p 10042:10042 \
    -p 10038:10038 \
    -p 10041:10041 \
    -p 10033:10033 \
    -p 10200:10200 \
    -p 10202:10202 \
    -p 10035:10035 \
    hcl/dx/core:v95_20190928-2258 \
    bash -c '/home/dx_user/checkVerifyProfile.sh;  if [ -f /opt/HCL/wp_profile/cloud/DX_CONFIGURED ]; then date ; else chmod 755 /opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh ; sed -i "/port=\"10041\"/a <aliases xmi:id=\"HostAlias_1566484479335\" hostname=\"*\" port=\"443\"/>" /opt/HCL/wp_profile/config/cells/dockerCell/virtualhosts.xml ; mkdir /opt/HCL/wp_profile/cloud; date ; /opt/HCL/AppServer/profiles/cw_profile/bin/startServer.sh server1; /opt/HCL/AppServer/profiles/cw_profile/ConfigEngine/ConfigEngine.sh action-create-webcontainer-properties-for-port -DWasPassword=wpsadmin; echo $(/opt/HCL/wp_profile/bin/startServer.sh WebSphere_Portal) > /opt/HCL/wp_profile/cloud/initServer.out ; echo $(/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh action-enable-invalidation-table -DWasPassword=wpsadmin) > /opt/HCL/wp_profile/cloud/cache.out ; echo $(/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh action-create-webcontainer-properties-for-port -DWasPassword=wpsadmin) > /opt/HCL/wp_profile/cloud/ports.out ; touch /opt/HCL/wp_profile/cloud/DX_CONFIGURED ; echo $(/opt/HCL/wp_profile/bin/stopServer.sh WebSphere_Portal -username wpsadmin -password wpsadmin) > /opt/HCL/wp_profile/cloud/serverStopped.out; fi'

sleep 180

docker rm -f $WEBSHERE_CONTAINER

docker run -itd --name $WEBSHERE_CONTAINER \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/$WEBSHERE_CONTAINER/opt/HCL/wp_profile:/opt/HCL/wp_profile:z \
    -e TZ=America/Mexico_City \
    -p 10039:10039 \
    -p 10042:10042 \
    -p 10038:10038 \
    -p 10041:10041 \
    -p 10033:10033 \
    -p 10200:10200 \
    -p 10202:10202 \
    -p 10035:10035 \
    hcl/dx/core:v95_20190928-2258 \
    bash -c '/home/dx_user/checkVerifyProfile.sh;  if [ -f /opt/HCL/wp_profile/cloud/DX_CONFIGURED ]; then date ; else chmod 755 /opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh ; sed -i "/port=\"10041\"/a <aliases xmi:id=\"HostAlias_1566484479335\" hostname=\"*\" port=\"443\"/> " /opt/HCL/wp_profile/config/cells/dockerCell/virtualhosts.xml ; mkdir /opt/HCL/wp_profile/cloud; date ; /opt/HCL/AppServer/profiles/cw_profile/bin/startServer.sh server1; /opt/HCL/AppServer/profiles/cw_profile/ConfigEngine/ConfigEngine.sh action-create-webcontainer-properties-for-port -DWasPassword=wpsadmin; echo $(/opt/HCL/wp_profile/bin/startServer.sh WebSphere_Portal) > /opt/HCL/wp_profile/cloud/initServer.out ; echo $(/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh action-enable-invalidation-table -DWasPassword=wpsadmin) > /opt/HCL/wp_profile/cloud/cache.out ; echo $(/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh action-create-webcontainer-properties-for-port -DWasPassword=wpsadmin) > /opt/HCL/wp_profile/cloud/ports.out ; touch /opt/HCL/wp_profile/cloud/DX_CONFIGURED ; echo $(/opt/HCL/wp_profile/bin/stopServer.sh WebSphere_Portal -username wpsadmin -password wpsadmin) > /opt/HCL/wp_profile/cloud/serverStopped.out; fi'

sleep 180

## Set up Webshere Portal 9

docker rm -f $WEBSHERE_CONTAINER

docker run -itd --name $WEBSHERE_CONTAINER \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/$WEBSHERE_CONTAINER/opt/HCL/wp_profile:/opt/HCL/wp_profile:z \
    -e TZ=America/Mexico_City \
    -p 10039:10039 \
    -p 10042:10042 \
    -p 10038:10038 \
    -p 10041:10041 \
    -p 10033:10033 \
    -p 10200:10200 \
    -p 10202:10202 \
    -p 10035:10035 \
    hcl/dx/core:v95_20190928-2258

sleep 120

echo "Webshere Portal is running on htpps://localhost:10041/ibm/console"
echo "First User: wpsadmin/wpsadmin"
```

Hasta este punto Webshere ya se encuentra expuesto en htpps://localhost:10041/ibm/console con el usuario por defecto **wpsadmin/wpsadmin**.

Para exponer el servicio detras de Nginx podemos apoyarnos del archivos de configuración [webshere.portal9.conf](conf/webshere.portal9.conf) ubicado en este repositorio.

