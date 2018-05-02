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

################################################################################
for (( i=0;i<$((365*3));i++ ))
do
    echo "Executing date ${P_DATA}"

    P_FULL_DATE=$(date --date="01 Jan 2015 09:00:00 BRST ${i} days")

    ${DIR}/bin/pdi-recharge-report-ndc.sh "${P_FULL_DATE}"

    if [ ${P_DATA} -eq 20160307 ]
    then
        echo "Backlog reprocessing finished."
        break
    fi
done

${DIR}/bin/run-report.sh

rm ${pidfile}
