#!/bin/bash
# Mauricio Melendez & Kev's Gomez | AMXGA/DT

NEXUS_DATA_DIRECTORY=/opt/sonatype/app/nexus
NEXUS_VERSION=3.19.1
NEXUS_BUILD=01
COMPOSER_VERSION=0.0.2
TARGET_DIR=/opt/sonatype/app/nexus/system/org/sonatype/nexus/plugins/nexus-repository-composer/${COMPOSER_VERSION}/
FIRST_RUN=0
MAIN_PID=$$
MAIN_PROC_RUN=1
env > /tmp/.env

trap "docker_stop" SIGINT SIGTERM
function docker_stop {
    echo "[AMX] Stopping the NEXUS server "
    /opt/sonatype/app/nexus/bin/nexus stop
    export MAIN_PROC_RUN=1
}

function check_variables(){
    NEXUS_VMOPTIONS=$(find / -name nexus.vmoptions)
    NEXUS_PROPERTIES=$(find / -name nexus.properties)

    if [ -n "${NEXUS_XMS}" ]; then
        sed -i "s%^-Xms.*%-Xms$NEXUS_XMS%g" $NEXUS_VMOPTIONS
    fi

    if [ -n "${NEXUS_XMX}" ]; then
        sed -i "s%^-Xmx.*%-Xms$NEXUS_XMX%g" $NEXUS_VMOPTIONS
    fi

    if [ -n "${NEXUS_MAX_DIRECTORY_MEMORY_SIZE}" ]; then
        sed -i "s%^-XX:MaxDirectMemorySize=.*%-XX:MaxDirectMemorySize=$NEXUS_MAX_DIRECTORY_MEMORY_SIZE%g" $NEXUS_VMOPTIONS
    fi

    if [ -n "${NEXUS_PREFER_IPV4}" ]; then
        sed -i "s%^-Djava.net.preferIPv4Stack=.*%-Djava.net.preferIPv4Stack=$NEXUS_PREFER_IPV4%g" $NEXUS_VMOPTIONS
    fi

    if [ -n "${NEXUS_HTTP_PORT}" ]; then
        cat /opt/sonatype/app/sonatype-work/nexus3/etc/nexus.properties | grep "^# application-port"
        if [ $? -eq 0 ]; then
            sed -i "s%^# application-port.*%application-port=$NEXUS_HTTP_PORT%g" $NEXUS_PROPERTIES
        else
            sed -i "s%^application-port.*%application-port=$NEXUS_HTTP_PORT%g" $NEXUS_PROPERTIES
        fi
    fi
}

if [ "$(ls -A $NEXUS_DATA_DIRECTORY)" ]; then
    echo "[AMX] Directory isn't empty"
    echo "[AMX] Starting Nexus..."
else
    echo "[AMX] Directory is empty"
    echo "[AMX] Install Nexus"
    mkdir -p /opt/sonatype/app && tar -xzf /root/nexus-3.19.1-01-unix.tar.gz -C /opt/sonatype/app
    mv /opt/sonatype/app/nexus-3.19.1-01 /opt/sonatype/app/nexus
    rm -f /opt/sonatype/app/nexus/bin/nexus.rc
    touch /opt/sonatype/app/nexus/bin/nexus.rc
    chmod 644 /opt/sonatype/app/nexus/bin/nexus.rc
    echo 'run_as_user="nexus"' >> /opt/sonatype/app/nexus/bin/nexus.rc
    echo "[AMX] Adding composer plugin"
    mkdir -p ${TARGET_DIR}
    cp /root/nexus-repository-composer-${COMPOSER_VERSION}.jar ${TARGET_DIR}
    sed -i 's@nexus-repository-maven</feature>@nexus-repository-maven</feature>\n        <feature prerequisite="false" dependency="false" version="0.0.2">nexus-repository-composer</feature>@g' /opt/sonatype/app/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}-${NEXUS_BUILD}/nexus-core-feature-${NEXUS_VERSION}-${NEXUS_BUILD}-features.xml
    sed -i 's@<feature name="nexus-repository-maven"@<feature name="nexus-repository-composer" description="org.sonatype.nexus.plugins:nexus-repository-composer" version="0.0.2">\n        <details>org.sonatype.nexus.plugins:nexus-repository-composer</details>\n        <bundle>mvn:org.sonatype.nexus.plugins/nexus-repository-composer/0.0.2</bundle>\n    </feature>\n    <feature name="nexus-repository-maven"@g' /opt/sonatype/app/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}-${NEXUS_BUILD}/nexus-core-feature-${NEXUS_VERSION}-${NEXUS_BUILD}-features.xml
    chown -R nexus:nexus /opt/sonatype/app
    ln -s /opt/sonatype/app/nexus/bin/nexus /etc/init.d/nexus
fi

while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 0 ] ; then
        FIRST_RUN=1
        chown -R nexus:nexus /opt/sonatype/app
        check_variables
        /opt/sonatype/app/nexus/bin/nexus start
        sleep 40
        echo "[AMX] Nexus started"
    fi
    sleep 2
done