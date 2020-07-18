#!/bin/bash

if [ -z "${GALERA_CONFIG_FILE}" ]; then
    GALERA_CONFIG_FILE="/etc/mysql/my.cnf"
fi

if [ ! -f "${GALERA_CONFIG_FILE}" ]; then
    cp /etc/my.cnf $GALERA_CONFIG_FILE
fi

if [ -z "${DEBUG}" ]; then
    DEBUG=0
fi

if [ -z "IS_MASTER" ]; then
    IS_MASTER=0
fi

EXPECTED_VOLUMES="/var/backups/mysqldailybackup /var/log/mysql /var/log/mysql/Binlogs /var/log/mysql/Bitacora /var/log/mysql/Audit /UD01/mysql/data /var/backups/ejecucionesscript /var/tmp/mysql"

if [ -z "$ephemeral" ]; then
    for expected_volume in ${EXPECTED_VOLUMES}; do
        if [ -f ${expected_volume}/deny-container-exec ]; then
            echo  "Error: volume ${expected_volume} not mounted."
            echo  "Mount: ${EXPECTED_VOLUMES}"
            exit 254
        fi
    done
else
    echo "WARNING THIS CONTAINER IS SET ON EPHEMERAL MODE AND WILL _NOT_ PERSIST DATA"
    for expected_volume in ${EXPECTED_VOLUMES}; do
        if [ ! -f ${expected_volume}/deny-container-exec ]; then
            echo  "Error: volume ${expected_volume} is mounted."
            echo  "Ephemeral mode won't accept mounted volumes"
            exit 254
        fi
    done
fi

echo "Setting up ${GALERA_CONFIG_FILE} variables"
env | grep galera_var_ | while read GALERA_VAR; do
    # var in lowercase ${var,,} | get the variable name with awk with the most left of split on = and replace variables that need a hypen -
    VAR=$(echo "${GALERA_VAR,,}" | awk '{split($0,a,"="); print a[1]}' | sed "s%galera_var_%%g" | sed -e "s%bind_address%bind-address%g" -e "s%character_set_client_handshake%character-set-client-handshake%" -e "s%character_set_server%character-set-server%"  -e "s%collation_server%collation-server%")
    # get the variable value, split, then print all args after an = and an = sign if there r more args
    VALUE=$(echo "$GALERA_VAR" | awk '{n=split($0,a,"="); for(i=2;i<=n;i++){printf a[i];if(i<n){printf "="}}}')
    # check if the var is on the doc
    VERIFY_VARIABLE=$(cat $GALERA_CONFIG_FILE | egrep "^$VAR" -o | awk '{split($0,a,"="); print a[1]}')
    # if the var is matched, replace it with sed
    if [ -n "${VERIFY_VARIABLE}" ]; then
        if [ ${DEBUG} -gt 0 ]; then
            echo "var and value: ${VAR} ${VALUE}"
            echo -e "my orig:\n\t" `egrep "^$VAR"  ${GALERA_CONFIG_FILE}| head -n 1`
            sed -i ${GALERA_CONFIG_FILE} -e "s%${VAR} *=.*%${VAR}=${VALUE}%"
            echo -e "my modif:\n\t" `egrep "^$VAR"  ${GALERA_CONFIG_FILE} | head -n 1`
        else
            sed -i ${GALERA_CONFIG_FILE} -e "s%${VAR} *=.*%${VAR}=${VALUE}%"
        fi
    else    
        echo "[AMX $(date +'%Y-%m-%d %R')] Variable $VAR isn't valid"
    fi
done



if [ -n "$ephemeral" ]; then
    rm -f /etc/mysql/deny-container-exec /UD01/mysql/data/deny-container-exec
fi

if [ -z "$(ls -A /UD01/mysql/data)" ]; then
    if [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
        echo >&2 'error: database is uninitialized and MYSQL_ROOT_PASSWORD not set'
        echo >&2 '  Did you forget to add -e "MYSQL_ROOT_PASSWORD=..." ?'
        exit 1
    fi

    echo "Initializing mysqld data dir"
    chown -R mysql:mysql /UD01/mysql/data
    chown -R mysql:mysql /var/log/mysql/
    chown -R mysql:mysql /var/tmp/mysql/
    /usr/sbin/mysqld --defaults-file=${GALERA_CONFIG_FILE} --initialize --user=mysql
    RC=$?
    if [ $RC -gt 0 ]; then
        echo "Error on mysql initialization"
        exit 2
    fi
    echo "Preparing root password script."
    # 2Do: proper SQL escaping on dat root password D:
    cat > /tmp/mysql-first-time.sql <<-EOSQL
            ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
            FLUSH PRIVILEGES ;
            SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
            FLUSH PRIVILEGES ;
            DROP DATABASE IF EXISTS test ;
EOSQL

    echo "Setup mysqld root password..."
    #/usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf  --user=mysql --wsrep-new-cluster
    export PASS=$(grep generated /var/log/mysql/Bitacora/mysqld.log |awk '{print $11}')
    echo $PASS
    /usr/bin/mysqladmin -uroot -p$PASS  password ${MYSQL_ROOT_PASSWORD}  
    exit_sucess=0

    for i in {1..5}; do
        sleep 1
        /usr/bin/mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD}  shutdown
        exit_sucess=$?
        if [ $exit_sucess -eq 0 ]; then
            echo "root password changed"
            break
        fi
    done
    if [ $IS_MASTER -gt 0 ]; then 
        exec  /usr/sbin/mysqld --defaults-file=${GALERA_CONFIG_FILE} --datadir=/UD01/mysql/data --user=mysql --wsrep-new-cluster
    else
        exec  /usr/sbin/mysqld --defaults-file=${GALERA_CONFIG_FILE} --datadir=/UD01/mysql/data --user=mysql
    fi 
else

    echo "init exec mysqld"
    chown -R mysql:mysql /UD01/mysql/data
    chown -R mysql:mysql /var/log/mysql/
    chown -R mysql:mysql /var/tmp/mysql/

    exec  /usr/sbin/mysqld --defaults-file=${GALERA_CONFIG_FILE} --datadir=/UD01/mysql/data --user=mysql 
fi