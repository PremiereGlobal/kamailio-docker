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

for var in $(compgen -e); do
  if [[ $var == KAM_* ]]; then
    echo "#!substdef \"!${var}!${!var}!g\"" >> "/etc/kamailio/vars.cfg"
  fi
done



exec "${@}"
