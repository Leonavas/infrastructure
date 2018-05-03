#!/bin/bash

source ~/.bash_profile

LOGFILE=/opt/openidea/acm/operator/claro/recharge/log/recharge_listener.log
DATA=$(date +%y%m%d%H%M%S)

echo -e "Staring compression of old recharge files at "$DATA >> $LOGFILE

cd /opt/openidea/acm/operator/claro/recharge/processed/
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
    tar --remove-files -zcf recharges_$DATA.tar.gz * >> $LOGFILE
    mv recharges_$DATA.tar.gz /opt/openidea/acm/operator/claro/recharge/pasture
else
    echo -e "Wrong path, watch out or you will compress the entire environment!"
    echo -e "Wrong path, watch out or you will compress the entire environment!" >> $LOGFILE
fi

echo -e "Generated tar file /opt/openidea/acm/operator/claro/recharge/processed/recharges_$DATA.tar" >> $LOGFILE
