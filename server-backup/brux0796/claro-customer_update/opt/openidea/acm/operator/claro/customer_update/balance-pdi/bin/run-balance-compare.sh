#!/bin/bash

if [ ! $# -eq 1 ]
then
    echo "Usage: $0 <OLD_PID>"
    exit 1
fi

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

NEW_BALANCE_SN_FN=${DIR}"/unp/UPLIFT_SALDOS_"${dt_1}"_00001.txt.gz"

mv ${DIR}/prc/${1} ${DIR}/prc/${P_PID}
mv ${DIR}/tmp/${1} ${DIR}/tmp/${P_PID}

${DIR}/bin/pdi-run-balance-compare.sh \
    ${P_PID} \
    ${dt_1} \
    ${NEW_BALANCE_SN_FN} > ${DIR}/log/run-crontab-${dt_1}.log

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job."
fi

${DIR}/bin/generate_campaign_exit.sh ${P_PID}

zip -j9 ${DIR}/log/run-crontab-${dt_1}.zip ${DIR}/log/run-crontab-${dt_1}.log
#echo "Sync complete" |/bin/mail -s "Sync execution completed: ${dt_1}" -a ${DIR}/log/run-crontab-${dt_1}.zip e_rcluiz@stefanini.com
rm ${DIR}/log/run-crontab-${dt_1}.zip

mv ${NEW_BALANCE_SN_FN} ${DIR}/prc/${P_PID}/

rm -f ${pidfile}
