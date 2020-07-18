#!/bin/bash


# --build-arg http_proxy=http://10.0.202.7:8080 \
docker build \
              -t linotp \
              . 
exit $?

