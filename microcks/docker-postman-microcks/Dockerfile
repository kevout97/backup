FROM dockeregistry.amovildigitalops.com/rhel7-atomic

LABEL maintainer="Mauricio Meléndez && Kevin Gómez / GADT-AMX"

RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash - && \
    curl https://repos.amxdigital.net/rhel-server-rhscl-7-rpms.repo  -o /etc/yum.repos.d/rhel-server-rhscl-7-rpms.repo && curl https://repos.amxdigital.net/rhel-7-server-rpms.repo -o /etc/yum.repos.d/rhel-7-server-rpms.repo && \
    microdnf install -y nodejs && microdnf clean all

# Define working directory
RUN mkdir -p /opt/app-root/src && mkdir -p /opt/app-root/src/lib
WORKDIR /opt/app-root/src

# Copy files and install dependencies
COPY /* /opt/app-root/src/
COPY /lib/* /opt/app-root/src/lib/
RUN npm install

# Set the running environment as production
ENV NODE_ENV production
ENV LOG_LEVEL info
ENV PORT 3000

# Expose on specified network port
EXPOSE 3000

# Executing defaults
CMD ["node", "app.js"]