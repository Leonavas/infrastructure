#!/bin/bash

if [ $# -eq 1 ]
then
    dt_1=$1
else
    dt_1=$(date --date="1 days ago" +%Y%m%d)
fi

P_PID=$$

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}"/run-balance-parser.pid"

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

NEW_BALANCE_SN_FN=$(find ${DIR}"/unp/UPLIFT_SALDOS_${dt_1}"*"_00001.txt.gz")

${DIR}/bin/pdi-balance-parser.sh \
    ${P_PID} \
    ${dt_1} \
    ${NEW_BALANCE_SN_FN} >> ${DIR}/log/run-balance-parser-${dt_1}.log

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job."
else
    mv ${DIR}"/tmp/"${P_PID}"/out/balance_analysis/Balance_Analysis_${dt_1}.csv.gz" ${DIR}"/prc/balance_analysis/."
fi

rm -rf ${NEW_BALANCE_SN_FN} ${pidfile} ${DIR}"/tmp/"${P_PID}
