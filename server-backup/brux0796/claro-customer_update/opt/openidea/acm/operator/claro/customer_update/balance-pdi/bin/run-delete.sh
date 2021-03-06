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

function should_stop {

    __CURRENT_DATE=$(date --date="0 days ago" +%Y%m%d)

    while [ -e ${pidfile} ]
    do
        if [ ${__CURRENT_DATE} -eq ${dt_0} ]
        then
            sleep 60
            __CURRENT_DATE=$(date --date="0 days ago" +%Y%m%d)
        else
            ${DIR}"/bin/stop.sh" ${P_PID}            
        fi
    done
}

should_stop &

${DIR}/bin/pdi-run-delete.sh $1 > ${DIR}/log/run-crontab-${dt_1}.log

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job."
fi

zip -j9 ${DIR}/log/run-crontab-${dt_1}.zip ${DIR}/log/run-crontab-${dt_1}.log
#echo "Sync complete" |/bin/mail -s "Sync execution completed: ${dt_1}" -a ${DIR}/log/run-crontab-${dt_1}.zip e_rcluiz@stefanini.com
rm ${DIR}/log/run-crontab-${dt_1}.zip

rm -f ${pidfile}
