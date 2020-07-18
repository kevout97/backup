FROM dockeregistry.amovildigitalops.com/rhel68db2105:v1.0

LABEL maintainer="Mauricio & Kevs | Amx GA/DT"

COPY entrypoint.sh /root/

USER root

RUN chmod +x /root/entrypoint.sh

ENTRYPOINT [ "/root/entrypoint.sh" ]