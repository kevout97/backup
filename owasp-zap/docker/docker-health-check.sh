#!/bin/bash

if [ -n "${ZAP_PORT_PROXY}" ]; then
    export ZAP_PORT=$ZAP_PORT_PROXY
fi

ZAP_PROXY_STATUS=$(ps aux | grep "java" | grep $ZAP_PORT | awk '{print $2}')
ZAP_WEB_STATUS=$(ps aux | grep java | awk '{print $2}' | head -n 1)

if [ -z "${ZAP_PROXY_STATUS}" ]; then
    exit 1
elif [ -z "${ZAP_WEB_STATUS}" ]; then
    exit 2
else
    exit 0
fi
