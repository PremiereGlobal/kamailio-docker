#!/usr/bin/dumb-init /bin/bash

. /env.sh

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
    echo "#!substdef \"!${var}!${!var}!g\"" >> "/etc/kamailio/vars.cfg"
  fi
done

if [[ -n ${KAM_DISPATCHER_ROUTES} ]]; then
  for rt in ${KAM_DISPATCHER_ROUTES/,/ }; do
    echo "kamctl dispatcher add 0 \"${rt}\""
  done
fi



exec "${@}"
