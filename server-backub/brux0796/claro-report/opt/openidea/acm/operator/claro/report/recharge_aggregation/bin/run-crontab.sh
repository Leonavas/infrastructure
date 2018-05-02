#!/bin/bash

DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}/cron.pid
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

${DIR}/bin/run-parse-incoming-file.sh >> ${DIR}/log/run-parse-incoming-file.log

if [ ! $? -eq 0 ]
then
    echo "Failed to parse incoming top up files."
    exit 1
fi

${DIR}/bin/run-report.sh >> ${DIR}/log/run-report.log

if [ ! $? -eq 0 ]
then
    echo "Failed to generate reports."
    exit 2
fi

rm ${pidfile}
