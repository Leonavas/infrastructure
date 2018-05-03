#!/bin/bash

dt_1=$(date --date="1 days ago" +%Y%m%d)

P_PID=$$

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}"/run-cust_campaign_characteristics-truncate.pid"

if [ -e ${pidfile} ];
then
    pid=$(cat ${pidfile})

    if kill -0 &> /dev/null ${pid};
    then
        echo "Already running"
        exit 1
    else
        rm ${pidfile}
    fi
fi

echo ${P_PID} > ${pidfile}

${DIR}/bin/pdi-cust_campaign_characteristics-truncate.sh > ${DIR}/log/run-cust_campaign_characteristics-truncate-${dt_1}.log

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job."
fi

rm -f ${pidfile}
