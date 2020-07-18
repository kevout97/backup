#!/bin/bash
#
# v 1.0 by: TheX2rider |  To the world with love, passion and fear
# v 1.1 by: Patricio M Dorantes Jamarne 
# v 1.2 by: Patricio M Dorantes Jamarne 
# v 2.0 by: Patricio M Dorantes Jamarne, dsc: nginx+php-fpm
# v 3.0 by: Fernndo Martinez, without nginx
# v 4.0 by: Mauricio Melendez & Kev's Gomez, add IBM extension
 
trap "docker_stop" SIGINT SIGTERM
STOP_PROC=0;
PHP_FPM_CONFD="/etc/opt/rh/rh-php72/php-fpm.d/"
PHP_FPM_PID=

# General entrypoint logging fc
log() {
  if [[ "$@" ]]; then echo "[ AMX | `date +'%Y-%m-%d %T'`] $@";
  else echo; fi
}
# 
print_config() {
  log "Current folder $PHP_FPM_CONFD:"
  printf '=%.0s' {1..100} && echo
  cat $PHP_FPM_CONFD/*
  printf '=%.0s' {1..100} && echo
}
function docker_stop {
    export STOP_PROC=1;
    log "Gracefully stopping php-fpm on pid $PHP_FPM_PID";
    kill -15 ${PHP_FPM_PID} 2>/dev/null
    kill -15 ${NGNX_PID} 2>/dev/null
}
#########
# Start # 
#########


log "Setting env variables..."

echo PHP_FPM_DATE_TZ=$PHP_FPM_DATE_TZ
echo PHP_FPM_DISPLAY_ERRORS=$PHP_FPM_DISPLAY_ERRORS
echo PHP_FPM_ERROR_LOG=$PHP_FPM_ERROR_LOG
echo PHP_FPM_INSECURE_THREADS_MEMORY=$PHP_FPM_INSECURE_THREADS_MEMORY
echo PHP_FPM_LOG_ERRORS=$PHP_FPM_LOG_ERRORS
echo PHP_FPM_MAX_CHILDREN=$PHP_FPM_MAX_CHILDREN
echo PHP_FPM_MAX_REQUESTS=$PHP_FPM_MAX_REQUESTS
echo PHP_FPM_REQUEST_TERMINATE_TIMEOUT=$PHP_FPM_REQUEST_TERMINATE_TIMEOUT
echo PHP_FPM_SESSION_HANDLER=$PHP_FPM_SESSION_HANDLER
echo PHP_FPM_SESSION_SAVE_PATH=$PHP_FPM_SESSION_SAVE_PATH
echo PHP_FPM_START_SERVERS=$PHP_FPM_START_SERVERS
echo PHP_FPM_THREAD_MEMORY_LIMIT=$PHP_FPM_THREAD_MEMORY_LIMIT

# PHP-FPM SESSION MANAGER
if [[ -n "${SESSION_HANDLER}" && -n ${SESSION_SAVE_PATH} ]]; then
    sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s/ *php_admin_value\[session.save_handler\].*/php_admin_value[session.save_handler]   = ${SESSION_HANDLER}/"
    sed -i ${PHP_FPM_CONFD}/www.conf \
        -e "s# *php_admin_value\[session.save_path\].*#php_admin_value[session.save_path]      = \"${SESSION_SAVE_PATH}\" #"
fi

# PHP-FPM PROCESS ADM
if [[ -n "${PHP_FPM_MAX_CHILDREN}" ]]; then
     sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s/ *pm.max_children.*/pm.max_children  = ${PHP_FPM_MAX_CHILDREN}/"
fi
if [[ -n "${PHP_FPM_START_SERVERS}" ]]; then
     sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s/ *pm.start_servers.*/pm.start_servers  = ${PHP_FPM_START_SERVERS}/" \
        -e "s/ *pm.min_spare_servers.*/pm.min_spare_servers  = ${PHP_FPM_START_SERVERS}/" \
        -e "s/ *pm.max_spare_servers.*/pm.max_spare_servers  = ${PHP_FPM_START_SERVERS}/" 
fi
if [[ -n "${PHP_FPM_MAX_REQUESTS}" ]]; then
     sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s/ *pm.max_requests.*/pm.max_requests  = ${PHP_FPM_MAX_REQUESTS}/" 
fi
if [[ -n "${PHP_FPM_REQUEST_TERMINATE_TIMEOUT}" ]]; then
    sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s/ *request_terminate_timeout.*/request_terminate_timeout  = ${PHP_FPM_REQUEST_TERMINATE_TIMEOUT}/"
fi
if [[ -n "${PHP_FPM_THREAD_MEMORY_LIMIT}" ]]; then
     sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s/ *php_admin_value\[memory_limit\].*/php_admin_value[memory_limit]  = ${PHP_FPM_THREAD_MEMORY_LIMIT}/"
fi
# PHP-FPM DEBUG CONTROL
# 2Do: check 4 admin flag
if [[ -n "${PHP_FPM_DISPLAY_ERRORS}" ]]; then
     sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s/ *php_flag\[display_errors\].*/php_flag[display_errors]  = ${PHP_FPM_DISPLAY_ERRORS}/"
fi
if [[ -n "${PHP_FPM_LOG_ERRORS}" ]]; then
     sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s/ *php_admin_flag\[log_errors\].*/php_admin_flag[log_errors]  = ${PHP_FPM_LOG_ERRORS}/"
fi
if [[ -n "${PHP_FPM_ERROR_LOG}" ]]; then
     sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s# *php_admin_value\[error_log\].*#php_admin_value[error_log]  = ${PHP_FPM_ERROR_LOG}#"
fi
# PHP-FPM TZ CONTROL
if [[ -n "${PHP_FPM_DATE_TZ}" ]]; then
     sed -i ${PHP_FPM_CONFD}/www.conf  \
        -e "s# *php_admin_value\[date.timezone\].*#php_admin_value[date.timezone]  = ${PHP_FPM_DATE_TZ}#"
fi

# Instance DB2
if [ "${instance_name}" ]; then
    chmod 777 /tmp
    useradd "${instance_name}"
    /opt/ibm/db2/V11.1/instance/db2icrt "${instance_name}"
    echo "ibm_db2.instance_name=${instance_name}" >> /etc/opt/rh/rh-php72/php.d/30-db2-ibm.ini
    echo "Instance db2 created"
else
    echo "Instance db2 not found."
    echo "You forgot to initialize instance_name."
    exit 2
fi


#chown -R apache:apache /var/www/sites/


log "Runing on config..."
print_config | sed -e 's/^/  /'

EXIT_CONTAINER=0

print_config
while [ $EXIT_CONTAINER -eq 0 ]; do
    if [ $STOP_PROC != 0 ]; then
        break;
    else
        # php-fpm
        if [[ -z "${PHP_FPM_PID}" || ! -d /proc/${PHP_FPM_PID} ]]; then
            php -v
            /opt/rh/rh-php72/root/usr/sbin/php-fpm -t 
            PHP_FPM_CONFIG_CHECK=$?
            if [ $PHP_FPM_CONFIG_CHECK -eq 0 ]; then
                /opt/rh/rh-php72/root/usr/sbin/php-fpm --nodaemonize &
                export PHP_FPM_PID=$!
            else
                log "php-fpm daemon configuration error"
                export STOP_PROC=1
                docker_stop
                break
            fi
        else
            # Proc running... 
            # 2Do: health stats report
            echo -n "."
        fi
        # end php
    fi
    sleep 1
done
log "Container end"
