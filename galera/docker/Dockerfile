FROM dockeregistry.amovildigitalops.com/rhel7-atomic
MAINTAINER "MHJR"

LABEL amx.container.version="1.0"
LABEL amx.container.categiry="RDBM"
LABEL amx.container.software="mysql_community_5.7_galera_cluster"
LABEL amx.org="DBA"

ENV REDHAT_FRONTEND noninteractive 

# Add galera repo
ADD galera.repo  /etc/yum.repos.d/galera.repo

# Get rhel7 repos

RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo \
    && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo  \
    && curl https://repos.amxdigital.net/rhui-rhel-7-server-rhui-optional-rpms.repo -o /etc/yum.repos.d/rhui-rhel-7-server-rhui-optional-rpms.repo \
    && curl https://repos.amxdigital.net/rhel-7-server-extras-rpms.repo -o /etc/yum.repos.d/rhel-7-server-extras-rpms.repo && \
    mkdir -p /var/backups/ejecucionesscript &&\
    mkdir -p /etc/mysql && \
    rpm --import https://releases.galeracluster.com/GPG-KEY-galeracluster.com && \
    microdnf clean all && \
    microdnf install -y perl-DBD-MySQL perl-Digest-MD5 libev openssl numactl-libs vi libaio ncurses procps hostname elfutils yum \
    tar.x86_64  lsof \
    openssl net-tools \
    openssl-devel socat boost-program-options \
    which rsync \
    galera-3 mysql-wsrep-5.7 && \
    yum install -y https://repo.percona.com/yum/release/8/RPMS/x86_64/percona-xtrabackup-80-8.0.11-1.el8.x86_64.rpm && \
    for dir in /var/backups/mysqldailybackup /var/log/mysql /var/log/mysql/Binlogs /var/log/mysql/Bitacora /var/log/mysql/Audit /UD01/mysql/data /var/backups/ejecucionesscript /var/tmp/mysql; do mkdir -p $dir; touch $dir/deny-container-exec; done

# Add my.cnf
COPY my.cnf /etc/
# Add entrypoint
ADD docker-entrypoint.sh /sbin/docker-entrypoint.sh
# Add fancy script
ADD cambiapass.sh /root/cambiapass.sh

# 4567 Galera Cluster replication gcomm://
# 3306 MySql default port
# 4568 Galera Incremental state transfer
# 4444 Galera state snapshot transfer
EXPOSE 4567/tcp 4567/udp 3306/tcp 4444/tcp 
ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
