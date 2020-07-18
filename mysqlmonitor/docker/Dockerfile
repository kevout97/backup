FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio & Kev's | AMX GA DT"

ENV MYSQL_MONITOR_VERSION=8.0.18

RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && \
    curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo
    
RUN microdnf clean all && \
    microdnf install wget unzip numactl-libs libaio ncurses procps hostname -y && \
    microdnf clean all && \
    echo "mysql:x:996:996:Mysql service:/home/mysql:/sbin/nologin" >> /etc/passwd && \
    echo "mysql:x:995:995:Mysqlmem user:/home/mysqlmem:/sbin/nologin" >> /etc/passwd && \
    echo "mysqlmonitor:x:2626:2626:Mysqlmonitor service:/home/mysqlmonitor:/sbin/nologin" >> /etc/passwd && \
    mkdir -p /opt/mysql/enterprise && \
    mkdir -p /opt/mysqlmonitor-files/{mysqlmonitor-server,mysqlmonitor-agent} && \
    wget https://nexus.san.gadt.amxdigital.net/repository/cloud/san/mysqlmonitor$MYSQL_MONITOR_VERSION-server.zip -P /opt/mysqlmonitor-files && \
    wget https://nexus.san.gadt.amxdigital.net/repository/cloud/san/mysqlmonitor$MYSQL_MONITOR_VERSION-agent.zip -P /opt/mysqlmonitor-files

COPY docker-entrypoint.sh /sbin

COPY docker-health-check.sh /sbin

RUN unzip /opt/mysqlmonitor-files/mysqlmonitor$MYSQL_MONITOR_VERSION-server.zip -d /opt/mysqlmonitor-files/mysqlmonitor-server && \
    unzip /opt/mysqlmonitor-files/mysqlmonitor$MYSQL_MONITOR_VERSION-agent.zip -d /opt/mysqlmonitor-files/mysqlmonitor-agent && \
    rm -f /opt/mysqlmonitor-files/mysqlmonitor$MYSQL_MONITOR_VERSION-server.zip && \
    rm -f /opt/mysqlmonitor-files/mysqlmonitor$MYSQL_MONITOR_VERSION-agent.zip && \
    mv /opt/mysqlmonitor-files/mysqlmonitor-agent/mysqlmonitoragent-$MYSQL_MONITOR_VERSION.1217-linux-x86-64bit-installer.bin /opt/mysqlmonitor-files/mysqlmonitor-agent/mysqlmonitoragent-$MYSQL_MONITOR_VERSION.installer.bin && \
    mv /opt/mysqlmonitor-files/mysqlmonitor-server/mysqlmonitor-$MYSQL_MONITOR_VERSION.1217-linux-x86_64-installer.bin /opt/mysqlmonitor-files/mysqlmonitor-server/mysqlmonitor-$MYSQL_MONITOR_VERSION.installer.bin && \
    chown 2626:0 -R /opt/mysqlmonitor-files && \
    chown 2626:0 -R /opt/mysql/enterprise

RUN chmod +x /sbin/docker-entrypoint.sh && \
    chmod +x /sbin/docker-health-check.sh

EXPOSE 18080 18443 13306

USER mysqlmonitor

ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]