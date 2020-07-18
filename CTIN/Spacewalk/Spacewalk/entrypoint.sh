#!/bin/bash

# Trap
trap "container_stop" SIGTERM SIGINT
export STOP=0;

function container_stop {
    export STOP=1;
}
# Ajuste de conexion a bd 
if [[ ! -z $DB_HOST && ! -z $DB_USER && ! -z $DB_PASS && ! -z $DB_NAME ]]; then
  sed -i "s%db-name.*%db-name=$DB_NAME%g" /tmp/answer
  sed -i "s%db-user.*%db-user=$DB_USER%g" /tmp/answer
  sed -i "s%db-pass.*%db-password=$DB_PASS%g" /tmp/answer
  sed -i "s%db-host.*%db-host=$DB_HOST%g" /tmp/answer
else 
  echo 'Es necesario especificar todos los siguientes campos: DB_HOST(IP), DB_USER, DB_PASS, DB_NAME'	
  exit 1; 
fi
# Configuracion de spacewalk
if [ ! -f "/tmp/.spacecookie" ]; then
    spacewalk-setup  --external-postgresql --answer-file=/tmp/answer --clear-db --skip-services-restart --non-interactive
    touch /tmp/.spacecookie
fi
# Inicio de servidor
if [ 0 -eq $(pgrep -x supervisord &>/dev/null && echo 1 || echo 0) ]; then
   /usr/sbin/taskomatic start        
  /usr/bin/supervisord -c /etc/supervisord.d/supervisord.conf 
fi
# Revision de estado
while true; do
    if [ $STOP != 0 ]; then
     if [ 0 -eq $(pgrep -x supervisord &>/dev/null && echo 1 || echo 0) ]; then
         echo "Reiniciando servicio de spacewalk $(date +%Y-%m-%d-%H:%M:%S)";
         /usr/bin/supervisord -c /etc/supervisord.d/supervisord.conf
	 echo "Servicio de spacewalk reiniciado";
         sleep 2;
        else
         echo "Trap encontrado. Spacewalk: OK"
        fi
    fi
    sleep 5;
done

