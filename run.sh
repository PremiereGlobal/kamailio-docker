#!/usr/bin/dumb-init /bin/bash

. /env.sh

DEFAULT_KAM_DEFINE_DB_MOD_FILE="db_sqlite.so"
DEFAULT_KAM_DEFINE_DBURL="sqlite:////etc/kamailio/kamailio.sqlite"
DEFAULT_KAM_DEFINE_WITH_UDP="true"
DEFAULT_KAM_DEFINE_WITH_TCP="true"
DEFAULT_KAM_DEFINE_WITH_TLS="true"
DEFAULT_KAM_DEFINE_WITH_WEBSOCKETS="true"
DEFAULT_KAM_DEFINE_WITH_USRLOCDB="true"
DEFAULT_KAM_DEFINE_WITH_ANTIFLOOD="true"
DEFAULT_KAM_DEFINE_WITH_LOADBALANCE="true"
DEFAULT_KAM_DEFINE_WITH_DEBUG="false"

DEFAULT_KAM_DEFINE_TLS_CONFIG_PATH="/etc/kamailio/tls_mod.cfg"
DEFAULT_KAM_INT_IP="0.0.0.0"
DEFAULT_KAM_EXT_IP="127.0.0.1"
DEFAULT_KAM_UDP_PORT="5060"
DEFAULT_KAM_TCP_PORT="5060"
DEFAULT_KAM_TLS_PORT="4443"


for var in ${!DEFAULT_KAM*}; do
  t=${var/DEFAULT_/}
  if [ -z ${!t} ]; then
    echo "Using default for ${t}:${!var}"
    eval ${t}=${!var}
    export "${t}"
  else
    echo "Using override value for ${t}"
  fi
done

for var in ${!KAM_*}; do
  if [[ $var == KAM_*  && "${var}" != "KAM_DISPATCHER_ROUTES" ]]; then
    if [[ $var == KAM_DEFINE_* && ${!var} != "false" ]]; then
      echo "#!define ${var/KAM_DEFINE_/} \"${!var}\"" >> "/etc/kamailio/defines.cfg"
    else
      echo "#!substdef \"!${var}!${!var}!g\"" >> "/etc/kamailio/vars.cfg"
    fi
  fi
done

if [[ -n ${KAM_DISPATCHER_ROUTES} ]]; then
  for rt in ${KAM_DISPATCHER_ROUTES/,/ }; do
    kamctl dispatcher add 0 "${rt}"
  done
fi

openssl req -x509 -newkey rsa:4096 -keyout /etc/kamailio/kamailio-selfsigned.key -out /etc/kamailio/kamailio-selfsigned.pem -days 36500 -subj '/CN=localhost' -sha256 -nodes

exec "${@}"
