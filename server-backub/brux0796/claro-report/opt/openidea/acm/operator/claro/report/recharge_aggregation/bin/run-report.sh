#!/bin/bash

DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}/recharge-report.pid
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

for DAY in $(find ${DIR}/out/uplift_recargas_msisdns_*.gz -mmin -1440 -type f | \
        sed "s:${DIR}/out/::g" | \
        awk '{l[substr($1,25,8)]} END{for (i in l){print i}}' | \
        sort -n -T ${DIR}/tmp); do

    echo ${DAY}

    ${DIR}/bin/pdi-recharge-report-ndc.sh ${DAY}

    if [ ! $? -eq 0 ]
    then
        echo "Failed executing Kettle job - Generate report from ${DAY} day."
        exit 1
    fi
done

${DIR}/bin/pdi-recharge-report-ndc-changes.sh

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job - Generate full report."
    exit 2
fi

rm ${pidfile}

