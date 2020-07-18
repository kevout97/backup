FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio Melendez & Kevin Gomez | AMX GADT"

ENV KONG_VERSION 1.4.2

RUN curl https://repos.amxdigital.net/rhui-rhel-7-server-rhui-rpms.repo  -o /etc/yum.repos.d/rhui-rhel-7-server-rhui-rpms.repo && \
	curl https://repos.amxdigital.net/rhui-rhel-server-rhui-rhscl-7-rpms.repo -o /etc/yum.repos.d/rhui-rhel-server-rhui-rhscl-7-rpms.repo && \
	curl https://repos.amxdigital.net/kong.repo -o /etc/yum.repos.d/kong.repo

RUN microdnf clean all && microdnf install procps yum -y

RUN yum install https://kong.bintray.com/kong-rpm/rhel/7/kong-$KONG_VERSION.rhel7.amd64.rpm -y \
	&& echo "kong:x:1337:1337:Kong Service:/home/kong:/sbin/nologin" >> /etc/passwd \
	&& mkdir -p /usr/local/kong \
    && chown -R kong:0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong \
	&& mkdir -p /etc/kong/conf 

COPY kong.conf /etc/kong/conf/

COPY docker-entrypoint.sh /sbin

COPY docker-health-check.sh /sbin

RUN chmod +x /sbin/docker-entrypoint.sh && \
	chmod +x /sbin/docker-health-check.sh && \
	chown -R kong:0 /etc/kong/conf

EXPOSE 8000 8443 8001 8444

USER kong

ENTRYPOINT [ "/sbin/docker-entrypoint.sh" ]