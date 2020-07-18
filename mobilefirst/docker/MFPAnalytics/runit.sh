#!/bin/bash
docker build -t dockeregistry.amovildigitalops.com/rhel7-atomic-mfanalytics8 /opt/MobileFirstAnalytics

docker run -it --rm --name MFAnalytics \
           -p 9082:9080 \
           -p 54328:54328 \
           -e ANALYTICS_ADMIN_USER=amxga \
           -e ANALYTICS_ADMIN_PASSWORD=abcd1234 \
           dockeregistry.amovildigitalops.com/rhel7-atomic-mfanalytics8