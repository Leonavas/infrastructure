#!/bin/bash

dt_0=$(date --date="0 days ago" +%Y%m%d)

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi

FILE=${DIR}"/ext/unp/score_zb/FX_SCORE_ZB.csv"
FILTER_FILE=${DIR}"/ext/unp/filter_score_zb.csv"

if [ -e ${FILE} ]
then
    dos2unix ${FILE}
    sed -i 's:\"::g;s:;:,:g' ${FILE}
    cat ${FILE} |sed '1d'|awk '{print $1";"$2}' FS="," > ${DIR}"/ext/unp/score_zb_${dt_0}.txt"
    cat ${FILE} |sed '1d'|awk '{print $1"|SCR_"$2}' FS="," > ${FILTER_FILE}
    echo "Copying file" ${FILTER_FILE} 
    scp ${FILTER_FILE} acm@brux0794:/opt/openidea/acm/operator/claro/report/smartphone/src/filter/.
    echo "Removing file" ${FILTER_FILE} 
    rm ${FILTER_FILE} 
    gzip ${DIR}"/ext/unp/score_zb_${dt_0}.txt"
    touch ${DIR}"/ext/unp/score_zb.file"
    mv ${FILE} ${DIR}"/ext/prc/"
    gzip ${DIR}"/ext/prc/"*".csv"
fi

