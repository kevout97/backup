FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio Meléndez && Kevin Gómez / GADT-AMX"

ENV REDIS_VERSION 5.0.5

RUN curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo && \
    microdnf install -y wget tar make gcc gzip diffutils && microdnf clean all && \
    mkdir -p /opt/redis.$REDIS_VERSION-files && \
    curl -o /opt/redis-$REDIS_VERSION.tar.gz http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz && tar xzf /opt/redis-$REDIS_VERSION.tar.gz -C /opt && rm -f /opt/*.tar.gz && \
    make -C /opt/redis-$REDIS_VERSION/deps hiredis jemalloc linenoise lua && \
    make -C /opt/redis-$REDIS_VERSION && \
    echo "redis:x:52872:52872:Redis Service:/home/redis:/sbin/nologin" >> /etc/passwd && \
    microdnf remove \
                autoconf \
                automake \
                cpp \
                gcc \
                gcc kernel-headers \
                glibc-devel \
                glibc-devel \
                glibc-headers \
                kernel-headers   \
                libgomp \
                libmpc \
                m4 \
                make \
                mpfr \
                pcre-devel

COPY redis.conf /opt/redis.$REDIS_VERSION-files 

COPY docker-health-check.sh docker-entrypoint.sh /sbin/

ENV PATH=$PATH:/opt/redis-$REDIS_VERSION/src/

EXPOSE 6379 26379

RUN touch /var/run/redis_6379.pid && \
    chown 52872:0 /var/run/redis_6379.pid && \
    mkdir -p /usr/local/etc/redis/ && \
    chown -R redis /usr/local/etc/redis/ && \
    chmod +x /sbin/docker-health-check.sh && \
    chmod +x /sbin/docker-entrypoint.sh && \
    echo "vm.overcommit_memory = 1" > /etc/sysctl.conf

USER redis

ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]
