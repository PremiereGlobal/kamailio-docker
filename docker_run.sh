#!/bin/bash

docker rm -f mysql-kamailio
docker rm -f kamailio
rm mysql_sock/mysqld.sock

docker run -v ${PWD}/mysql_sock:/var/run/mysqld --name mysql-kamailio -e MYSQL_ROOT_PASSWORD=mysql_root_pass -e MYSQL_USER=kamailiorw -e MYSQL_PASSWORD=kamailiorw -e MYSQL_DATABASE=kamailio -itd mysql:5.6 --socket=/var/run/mysqld/mysqld.sock

sleep 10

docker run -v ${PWD}/mysql_sock:/var/run/mysqld -v ${PWD}/ssl:/etc/kamailio/ssl --network host --name kamailio -p 443:443/tcp -p 5060:5060/udp -p 5060:5060/tcp -p 5061:5061/tcp -itd readytalk/kamailio-docker:latest
