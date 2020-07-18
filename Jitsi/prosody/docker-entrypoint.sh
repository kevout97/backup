#!/bin/bash

FIRST_RUN=1
MAIN_PROC_RUN=1

if [ -z "${JICOFO_AUTH_DOMAIN}" ]; then
    JICOFO_AUTH_DOMAIN="auth.claroconnect.com"
fi

if [ -z "${JICOFO_FOCUS_PASSWORD}" ]; then
    JICOFO_FOCUS_PASSWORD="fa8DmGQk"
fi

if [ -z "${JICOFO_JVB_PASSWORD}" ]; then
    JICOFO_JVB_PASSWORD="JWlc6CDg"
fi

if [ -z "${JICOFO_JVB_USER}" ]; then
    JICOFO_JVB_USER="jvb"
fi

if [ -z "${JICOFO_FOCUS_USER}" ]; then
    JICOFO_FOCUS_USER="focus"
fi

prosodyctl register $JICOFO_FOCUS_USER $JICOFO_AUTH_DOMAIN $JICOFO_FOCUS_PASSWORD
prosodyctl register $JICOFO_JVB_USER $JICOFO_AUTH_DOMAIN $JICOFO_JVB_PASSWORD
while [ ${MAIN_PROC_RUN} -eq 1 ]; do
    if [ "${FIRST_RUN}" -eq 1 ] ; then
        FIRST_RUN=0
        #prosody -F
        prosodyctl restart
    fi
    sleep 15
done