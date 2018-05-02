#!/bin/bash

DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation

if [ $# -eq 1 ]
then
    IN_REP_DATE=$(date --date="${1}" +%Y%m%d)
else
    echo "usage $0 <IN_REP_DATE>"
    exit 1
fi

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}/recharge-detailed-report.pid
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

${DIR}/bin/pdi-recharge-report.sh ${IN_REP_DATE}

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job - Generate full report."
    exit 2
fi

rm ${pidfile}

