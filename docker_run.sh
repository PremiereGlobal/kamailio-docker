#!/bin/bash

docker rm -f mysql-kamailio
docker rm -f kamailio

docker run -v ${PWD}/mysql_sock:/var/run/mysqld -v ${PWD}/ssl:/etc/kamailio/ssl --network host --name kamailio -p 443:443/tcp -p 5060:5060/udp -p 5060:5060/tcp -p 5061:5061/tcp -itd readytalk/kamailio-docker:latest
