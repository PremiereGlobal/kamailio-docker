FROM debian:9

RUN apt-get update && apt-get install -y \
      kamailio \
      kamailio-websocket-modules \
      kamailio-mysql-modules \
      kamailio-tls-modules \
      kamailio-presence-modules \
      procps \
      curl \
    && apt-get clean && rm -rf /var/lib/apt/lists

WORKDIR /root

ENV INSTALL_EXTRA_TABLES=yes
ENV INSTALL_PRESENCE_TABLES=yes
ENV INSTALL_DBUID_TABLES=yes
ENV SIPDOMAIN=sip.domain.com
ENV PW="mysql_root_pass"
ENV MYSQL_PASS="mysql_root_pass"
ENV MYSQL_HOST="db.somedomain.com"

ADD ./kamctlrc /etc/kamailio/kamctlrc
ADD run.sh /run.sh
RUN chmod +x /run.sh
CMD /run.sh
