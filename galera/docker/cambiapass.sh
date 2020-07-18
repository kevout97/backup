#!/bin/bash

export PASS=(`grep generated /var/log/mysql/Bitacora/mysqld.log |awk '{print $11}'`)
    echo $PASS
    /usr/bin/mysqladmin -uroot -p$PASS  password ${MYSQL_ROOT_PASSWORD} 
