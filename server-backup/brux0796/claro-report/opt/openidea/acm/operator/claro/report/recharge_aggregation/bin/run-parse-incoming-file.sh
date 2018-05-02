#!/bin/bash

DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}/recharge-reorg.pid
if [ -e ${pidfile} ]
then
    pid=$(cat ${pidfile})

    if kill -0 &> /dev/null ${pid}
    then
        echo "Already running"
        exit 1
    else
        rm ${pidfile}
    fi
fi
echo $$ > ${pidfile}

PRC_PID=$$

################################################################################
################################################################################
${DIR}/bin/pdi-recharge-aggregator.sh ${PRC_PID} ${DIR}"/unp" ${DIR}"/out"

rm -fr ${DIR}/tmp/${PRC_PID}

rm ${pidfile}
