#!/bin/bash




HOSTS="10.10.10.10 10.11.12.13 10.10.10.11"

UDP_PORTS="4567"
TCP_PORTS="4567 4568 4444 3307"

for host in ${HOSTS}; do

    for port in ${TCP_PORTS}; do 
        firewall-cmd  --add-rich-rule="rule family=ipv4 port port=${port} protocol=tcp accept source address=${host}"
    done
    for port in ${UDP_PORTS}; do 
        firewall-cmd  --add-rich-rule="rule family=ipv4 port port=${port} protocol=udp accept source address=${host}"
    done
done

