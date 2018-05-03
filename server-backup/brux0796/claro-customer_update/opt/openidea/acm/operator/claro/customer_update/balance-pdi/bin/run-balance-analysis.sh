#!/bin/bash

dt_1=$(date --date="1 days ago" +%Y%m%d)
P_PID=$$
DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}"/run-balance-analysis.pid"

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

${DIR}/bin/pdi-balance-analysis.sh > ${DIR}/log/run-balance-analysis-${dt_1}.log

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job."
else
    OUT_FILE=${DIR}/out/balance_analysis/Balance_Analysis_${dt_1}.txt
    zcat ${DIR}/out/balance_analysis/Balance_Analysis.txt.gz > ${OUT_FILE}
    zcat ${DIR}/out/balance_analysis/Balance_Analysis_History.csv.gz >> ${OUT_FILE}
    mv ${OUT_FILE} ${DIR}/out/balance_analysis/Balance_Analysis.txt
    rm ${DIR}/out/balance_analysis/Balance_Analysis.txt.gz
    gzip -9 ${DIR}/out/balance_analysis/Balance_Analysis.txt
fi

rm -f ${pidfile}
