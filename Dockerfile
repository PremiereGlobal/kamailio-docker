FROM alpine:latest

RUN apk add --no-cache kamailio kamailio-websocket kamailio-mysql kamailio-tls kamailio-sqlite kamailio-utils kamailio-utils kamailio-extras curl tcpdump dumb-init sqlite


ADD ./configs/* /etc/kamailio/
RUN mkdir /etc/kamailio/routes
ADD ./configs/routes/* /etc/kamailio/routes/
ADD run.sh /run.sh
RUN chmod +x /run.sh
RUN kamdbctl create /etc/kamailio/kamailio.sqlite
ENTRYPOINT ["/run.sh"]
CMD ["/usr/sbin/kamailio", "-DD", "-P", "/var/run/kamailio.pid", "-f", "/etc/kamailio/kamailio.cfg"]
