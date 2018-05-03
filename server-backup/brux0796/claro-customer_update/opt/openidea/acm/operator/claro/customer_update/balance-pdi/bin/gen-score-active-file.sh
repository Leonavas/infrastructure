#!/bin/bash

dt_0=$(date --date="0 days ago" +%Y%m%d)

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi

FILE=${DIR}"/ext/unp/score_ativo/FX_SCORE_ATIVO.csv"

if [ -e ${FILE} ]
then
    dos2unix ${FILE}
    sed -i 's:\"::g' ${FILE}
    cat ${FILE} |sed '1d'|awk '{print $1";"$2}' FS="," > ${DIR}"/ext/unp/score_active_${dt_0}.txt"
    gzip ${DIR}"/ext/unp/score_active_${dt_0}.txt"
    touch ${DIR}"/ext/unp/score_active.file"
    mv ${FILE} ${DIR}"/ext/prc/"
fi
