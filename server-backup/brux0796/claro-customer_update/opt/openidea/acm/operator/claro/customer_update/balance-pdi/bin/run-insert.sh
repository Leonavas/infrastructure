#!/bin/bash

dt_0=$(date --date="0 days ago" +%Y%m%d)
dt_1=$(date --date="1 days ago" +%Y%m%d)
dt_2=$(date --date="2 days ago" +%Y%m%d)

P_PID=$$

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}"/run-crontab.pid"

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

${DIR}/bin/pdi-run-insert.sh $1 > ${DIR}/log/run-insert-${dt_1}.log

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job."
fi

rm -f ${pidfile}
