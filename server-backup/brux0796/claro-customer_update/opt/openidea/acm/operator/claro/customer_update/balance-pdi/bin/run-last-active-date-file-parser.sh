#!/bin/bash

if [ $# -eq 2 ]
then
    dt_0=$1
    dt_1=$2
else
    echo "Usage $0 <OLD_DATE: yyyyMMdd> <NEW_DATE: yyyyMMdd>"
    exit 1
fi

P_PID=$$

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}"/run-last-active-date-file-parser.pid"

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

TMP_DIR=${DIR}"/ext/last_active_date/tmp/"${P_PID}

mkdir -p ${TMP_DIR}

OLD_LAST_ACTIVE_DATE=${DIR}"/ext/last_active_date/last_active_date_${dt_0}.txt.gz"
NEW_LAST_ACTIVE_DATE=${DIR}"/ext/last_active_date/last_active_date_${dt_1}"

scp brux0794:/opt/openidea/acm/operator/claro/report/wpp_balance/src/UPLIFT_SALDOS_${dt_1}*_00001.txt.gz ${TMP_DIR}
if [ ! $? -eq 0 ]
then
    echo "Failed to retrieve file UPLIFT_SALDOS_${dt_1}_00001.txt.gz from server brux0794"
    scp brux0795:/opt/openidea/acm/operator/claro/report/wpp_balance/src/UPLIFT_SALDOS_${dt_1}*_00001.txt.gz ${TMP_DIR}
    if [ ! $? -eq 0 ]
    then
        echo "Failed to retrieve file UPLIFT_SALDOS_${dt_1}_00001.txt.gz from server brux0795"
        mv ${OLD_LAST_ACTIVE_DATE} ${NEW_LAST_ACTIVE_DATE}".txt.gz"
        rm -rf ${pidfile} ${TMP_DIR}
        exit 2
    fi
fi

NEW_BALANCE_SN_FN=$(find ${TMP_DIR}"/UPLIFT_SALDOS_${dt_1}"*"_00001.txt.gz")

${DIR}/bin/pdi-last-active-date-file-parser.sh \
    "${P_PID}" \
    "${NEW_BALANCE_SN_FN}" \
    "${OLD_LAST_ACTIVE_DATE}" \
    "${NEW_LAST_ACTIVE_DATE}" >> ${DIR}/log/pdi-last-active-date-file-parser.log

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job."
else
    rm -r ${TMP_DIR}
fi

rm ${pidfile}
