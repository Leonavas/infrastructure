#!/bin/bash

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi
P_PID=$1
DEL_DIR=${DIR}"/tmp/"${P_PID}"/out/delete"
PRC_DIR=${DIR}"/prc/"${P_PID}
EVT_DIR="/opt/openidea/acm/operator/claro/event_process"
DEST_DIR=${EVT_DIR}"/event/campaign_exit/src/all"

for __file in ${DEL_DIR}"/delete_with_campaign_"*".gz"
do
    if [ -e ${__file} ]
    then
        zcat ${__file} |sed '1d' | awk '{print $1}' FS="|" >> ${DEL_DIR}"/campaign_exit.csv"
        mv ${__file} ${PRC_DIR}/
    fi
done

if [ -e ${DEL_DIR}"/campaign_exit.csv" ]
then
    cat ${DEL_DIR}"/campaign_exit.csv" |sort -R -T ${DEL_DIR}/ > ${DEL_DIR}"/campaign_exit.csv.sort"
    mv ${DEL_DIR}"/campaign_exit.csv.sort" ${DEL_DIR}"/campaign_exit.csv"
    mv ${DEL_DIR}"/campaign_exit.csv" ${DEST_DIR}/
    $EVT_DIR/generic_input.sh $EVT_DIR/cfg/campaign_exit/all.cfg
fi

if [ -e ${DIR}"/tmp/"${P_PID}"/out/final/balance_1.txt.gz" ]
then
    zcat ${DIR}"/tmp/"${P_PID}"/out/final/balance_1.txt.gz" |sed '1d'|awk '{if ($18 == "1" && $22 > 0){print $1}}' FS="|" | sort -R -T ${DIR} > ${DEST_DIR}/campaign_exit_ucg.csv
    $EVT_DIR/generic_input.sh $EVT_DIR/cfg/campaign_exit/all.cfg

    zcat ${DIR}"/tmp/"${P_PID}"/out/final/balance_1.txt.gz" |sed '1d'|awk '{if ($5 == "A" && $15 > 0 && $22 > 0){print $1}}' FS="|" | sort -R -T ${DIR} > ${DIR}"/tmp/"${P_PID}"/out/final/saida_optin_ativos.csv"
fi
