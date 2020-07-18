FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio & Kev | AMX GADT"

USER root

RUN curl https://repos.amxdigital.net/rhui-rhel-7-server-rhui-rpms.repo  -o /etc/yum.repos.d/rhui-rhel-7-server-rhui-rpms.repo && \
	curl https://repos.amxdigital.net/rhui-rhel-server-rhui-rhscl-7-rpms.repo -o /etc/yum.repos.d/rhui-rhel-server-rhui-rhscl-7-rpms.repo && \
	curl https://repos.amxdigital.net/rhui-rhel-7-server-rhui-optional-rpms.repo -o /etc/yum.repos.d/rhui-rhel-7-server-rhui-optional-rpms.repo && \
	microdnf install yum && \
	yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
	yum install -y http://li.nux.ro/download/nux/dextop/el7/x86_64//pyxdg-0.25-2.el7.nux.noarch.rpm \
		java-1.8.0-openjdk \
		x11vnc \
		xmlstarlet \
		openbox \
		xterm \
		tar \
		wget \
		python3-pip \
		firefox \
		xorg-x11-server-Xvfb \
		git \
		unzip \
		net-tools \
		which && \
	curl -O https://bootstrap.pypa.io/get-pip.py && \
	python get-pip.py && \
	rm -rf get-pip.py && \
	pip install --upgrade pip zapcli python-owasp-zap-v2.4==0.0.14 && \
	pip3 install --upgrade pip zapcli python-owasp-zap-v2.4==0.0.14 && \
	echo "zap:x:1001:1001::/home/zap:/bin/bash" >> /etc/passwd && \
	mkdir -p /home/zap && \
	mkdir /opt/owasp-zap/sesiones -p && chown 1001:1001 -R /opt/owasp-zap /home/zap

WORKDIR /opt/owasp-zap

USER zap

RUN mkdir /home/zap/.vnc && \
	curl -s https://raw.githubusercontent.com/zaproxy/zap-admin/master/ZapVersions.xml | xmlstarlet sel -t -v //url |grep -i Linux | wget -nv --content-disposition -i - -O - | tar zxv && \
	cp -R ZAP*/* . &&  \
	rm -R ZAP* && \
	curl -s -L https://bitbucket.org/meszarv/webswing/downloads/webswing-2.5.10.zip > webswing.zip && \
	unzip webswing.zip && \
	rm webswing.zip && \
	mv webswing-* webswing && \
	rm -R webswing/demo/ && \
	touch AcceptedLicense

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.242.b08-0.el7_7.x86_64/jre/ 
ENV PATH $JAVA_HOME/bin:/opt/owasp-zap/:$PATH
ENV ZAP_PATH /opt/owasp-zap/zap.sh
ENV LC_ALL=en_US.utf-8
ENV LANG=en_US.utf-8
ENV ZAP_PORT 9090
ENV HOME /home/zap/
ENV LD_LIBRARY_PATH /opt/rh/devtoolset-3/root/usr/lib64/

COPY zap* /opt/owasp-zap/
COPY webswing.config /opt/owasp-zap/webswing/
COPY policies /home/zap/.ZAP/policies/
COPY scripts /home/zap/.ZAP_D/scripts/
COPY .xinitrc /home/zap/
COPY docker-* /sbin/

USER root

RUN chown 1001:1001 /opt/owasp-zap/* && \
	chown 1001:1001 /opt/owasp-zap/webswing/webswing.config && \
	chown 1001:1001 -R /home/zap/.ZAP/ && \
	chown 1001:1001 /home/zap/.xinitrc && \
	chmod a+x /home/zap/.xinitrc && \
	chmod +x /sbin/docker-entrypoint.sh && chmod +x /sbin/docker-health-check.sh

USER zap

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]

HEALTHCHECK --retries=5 --interval=5s CMD /sbin/docker-health-check.sh
