FROM ubuntu:18.04

RUN apt-get update && apt-get install -y kamailio kamailio-mysql-modules kamailio-sqlite-modules kamailio-tls-modules kamailio-websocket-modules curl tcpdump sqlite

#setup dumb-init
RUN curl -k -L https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 > /usr/bin/dumb-init
RUN chmod 755 /usr/bin/dumb-init

ADD ./configs /etc/kamailio
ADD run.sh /run.sh
RUN chmod +x /run.sh
RUN kamdbctl create /etc/kamailio/kamailio.sqlite
RUN touch /env.sh
ENTRYPOINT ["/run.sh"]
CMD ["/usr/sbin/kamailio", "-DD", "-P", "/var/run/kamailio.pid", "-f", "/etc/kamailio/kamailio.cfg"]
