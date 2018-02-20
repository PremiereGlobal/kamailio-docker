#! /bin/sh
sleep 10
set -x

echo "Copying the default config"
cp /kamailio.cfg /etc/kamailio/kamailio.cfg

echo "Setting options...."
OPTIONS=""

# Discover public and private IP for this instance (AWS Specific)
export PRIVATE_IPV4="$(curl --fail -qs http://169.254.169.254/latest/meta-data/local-ipv4)"
export PUBLIC_IPV4="$(curl --fail -qs http://169.254.169.254/latest/meta-data/public-ipv4)"

for thingy in /etc/kamailio/kamailio.cfg /etc/kamailio/kamctlrc
do
    echo "Setting variables in $thingy...."
    sed -i "s/MYSQL_HOST/${MYSQL_HOST}/g" $thingy
    sed -i "s/MYSQL_PASS/${MYSQL_PASS}/g" $thingy
    sed -i "s/\!MY_IP_ADDR\!xxx.xxx.xxx.xxx\!g/\!MY_IP_ADDR\!${PRIVATE_IPV4}\!g/g" $thingy
    sed -i "s/xxx.xxx.xxx.xxx\ advertise\ xxx.xxx.xxx.xxx/${PRIVATE_IPV4}\ advertise\ ${PUBLIC_IPV4}\:5060/g" $thingy
    sed -i "s/pinger\@domain.com/${SIPDOMAIN}/g" $thingy
    sed -i "s/HOMER_DEST/${HOMER_DEST}/g" $thingy
    sed -i "s/HOMER_CAP_ID/${HOMER_CAP_ID}/g" $thingy
done

# Insert all the possible domains that might be considered to be myself
for thingy in $POSSIBLE_DOMAINS; do
    sed -i "s@##POSSIBLE_DOMAINS@##POSSIBLE_DOMAINS\\nmodparam(\"corex\", \"alias_subdomains\", \"${thingy}\")@" /etc/kamailio/kamailio.cfg
done

set +x

echo "###################################"
echo "######        kamctlrc      #######"
echo "###################################"
cat /etc/kamailio/kamctlrc

echo "###################################"
echo "######    kamailio.cfg      #######"
echo "###################################"
cat /etc/kamailio/kamailio.cfg

exec /usr/sbin/kamailio -m $KAMAILIO_SH_MEM -M $KAMAILIO_PKG_MEM -DD -P /var/run/kamailio.pid -f /etc/kamailio/kamailio.cfg
