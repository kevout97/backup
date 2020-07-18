#!/bin/bash

if [ ! -d "/home/dasusr" ]; then
    cd /home;
    tar -xzf /root/dasusr.tar.gz
fi

if [ `ls -l /home/ | egrep -v total | grep -v lost+found | wc -l` -eq 1 ]; then
    if [[ -z "$instuser" || -z "$instport" || -z "$instpasswd" ]]; then
        echo "This container requires an instance name, a port number and a password"
        exit 0
    else
        useradd -m $instuser;
        echo "$instuser:$instpasswd" | chpasswd;
        echo "DB2_$instuser         $instport/tcp" >> /etc/services
        /opt/IBM/db2/V10.5/instance/db2icrt -p DB2_$instuser -s ese -u $instuser $instuser
        su - $instuser -c "db2set DB2COMM=TCPIP"
        su - $instuser -c "db2start"
    fi
else
    if [ -d "/home/$instuser" ]; then
        #uid=`stat -c "%u" /home/$instuser`
        #gid=`stat -c "%g" /home/$instuser`
        /opt/IBM/db2/V10.5/instance/db2iset -a $instance
        mv /home/.passwd /etc/passwd
        mv /home/.group /etc/group
        mv /home/.shadow /etc/shadow
        mv /home/.services /etc/services
    fi
fi

cp /etc/passwd /home/.passwd
cp /etc/group /home/.group
cp /etc/shadow /home/.shadow
cp /etc/services /home/.services

for i in `ls /home/ | grep -v lost+found`; do
    if [ $i != "dasusr"  ]; then
        instdetected=$i;
        su - $i -c "db2start";
    fi
done

while true
do
    sleep 10000 &
    export spid=${!}
    wait $spid
done
