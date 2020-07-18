#!/bin/bash

# Trap
trap "container_stop" SIGTERM SIGINT
export STOP=0;

function container_stop {
    export STOP=1;
}

# Creacion de usuario 
if [ ! -z $LIN_PASS ];then
 echo "Creando usuario"
 user=${LIN_USER:-"AMX"}
 realm=${LIN_REALM:-"AMX"} 
 digest="$( printf "%s:%s:%s" "$user" "$realm" "$LIN_PASS" | md5sum | awk '{print $1}' )"
 printf "%s:%s:%s\n" "$user" "$realm" "$digest" > /etc/linotp2/admins
 sed -i 's%AuthName.*%AuthName '$realm'%g' /etc/httpd/conf.d/linotp.conf
else
  echo 'Es necesario especificar un password de usuario: -e LIN_PASS=PASWORD'   
  exit 1; 
fi
# Ajuste de conexion a bd 
if [[ ! -z $DB_HOST && ! -z $DB_USER && ! -z $DB_PASS && ! -z $DB_NAME ]];then
 echo "Configurando base de datos"
 sed -i "s%sqlalchemy.url.*%sqlalchemy.url = mysql://$DB_USER:$DB_PASS@$DB_HOST/$DB_NAME%g" /etc/linotp2/linotp.ini
else 
  echo 'Es necesario especificar todos los siguientes campos: -e DB_HOST(IP), -e DB_USER, -e DB_PASS,-e DB_NAME'	
  exit 1; 
fi
# Configuracion de linotp
if [ ! -f "/tmp/.lincookie" ];then
 echo "Configurando Linotp..."
 sed -i "s%port.*%port = 80%g" /etc/linotp2/linotp.ini
 paster setup-app /etc/linotp2/linotp.ini
 paster serve /etc/linotp2/linotp.ini  &
 sleep 20
 wget  http://127.0.0.1:80  
 pkill paster
 sleep 10
 chown -R linotp /etc/linotp2/data/templates/ /etc/linotp2/encKey /var/log/linotp/ /etc/linotp2/linotp.ini
 touch /tmp/.lincookie
fi
# Inicio de servidor
if [ 0 -eq $(pgrep -x supervisord &>/dev/null && echo 1 || echo 0) ]; then
 echo "Iniciando servicio"
 /usr/bin/supervisord -c /etc/supervisord.d/supervisord.conf 
fi
# Revision de estado
while true; do
    if [ $STOP != 0 ]; then
     if [ 0 -eq $(pgrep -x supervisord &>/dev/null && echo 1 || echo 0) ];then
         echo "Reiniciando servicio Linotp $(date +%Y-%m-%d-%H:%M:%S)";
         /usr/bin/supervisord -c /etc/supervisord.d/supervisord.conf
	 echo "Servicio Linotp reiniciado";
         sleep 2;
        else
         echo "Trap encontrado. Linotp: OK"
        fi
    fi
    sleep 5;
done
