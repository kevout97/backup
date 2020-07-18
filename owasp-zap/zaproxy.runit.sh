#!/bin/bash
mkdir -p /var/containers/owasp-zaproxy/opt/owasp-zaproxy/{sesiones,files}
chown 1001:0 -R /var/containers/owasp-zaproxy/

docker run -itd --name owasp-zaproxy \
    -h zap.example.com \
    -v /etc/localtime:/etc/localtime:ro \
    -v /var/containers/owasp-zaproxy/opt/owasp-zaproxy/sesiones:/opt/owasp-zaproxy/sesiones:z \
    -v /var/containers/owasp-zaproxy/opt/owasp-zaproxy/files:/opt/owasp-zaproxy/files:z \
    -e TZ=America/Mexico_City \
    -e ZAP_FULL_SCAN=false \
    -p 9090:9090 \
    -p 8080:8080 \
    dockeregistry.amovildigitalops.com/atomic-rhel7-owasp-zap
