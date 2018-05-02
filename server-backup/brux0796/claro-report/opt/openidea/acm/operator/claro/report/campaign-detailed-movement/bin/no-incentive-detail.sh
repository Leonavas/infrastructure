#!/bin/bash

if [ $# -eq 1 ];
then
    INPUT_DATE=$1
else
    exit 1
fi

PENTAHO_JAVA_HOME="/opt/openidea/programs/jdk1.8.0_65"
export PENTAHO_JAVA_HOME
KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-7.0.0.0-25/data-integration/"

export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

DIR=/opt/openidea/acm/operator/claro/report/campaign-detailed-movement

OUT_TMP_DIR=$DIR"/tmp/"$$

mkdir -p ${OUT_TMP_DIR}

BALANCE_DATE=$(date --date="1 days ago" +%Y%m%d)

EXT_DATA_DIR="/opt/openidea/acm/operator/claro/files/balance"
FILE_BALANCE=${EXT_DATA_DIR}"/balance_prepago_"${BALANCE_DATE}".txt.gz"
FILE_NO_INCENTIVE=${DIR}"/ans/"${INPUT_DATE}"/without-incentive.txt.gz"

$PDI_BIN -file="$DIR"/pdi/job/no-incentive-detail.kjb -level=basic \
    " -param:acm.job.file.in.balance="${FILE_BALANCE} \
    " -param:acm.job.file.in.no-incentive="${FILE_NO_INCENTIVE} \
    " -param:acm.job.file.out="${OUT_TMP_DIR}"/without-incentive-detail" \
> ${DIR}/log/no-incentive-detail-${INPUT_DATE}.log 2>&1

if [ $? -eq 0 -o $? -eq 142 ]; then

    echo "PDI return code: " $?

    if [ -f ${OUT_TMP_DIR}"/without-incentive-detail.txt.gz" ]; then
        mv ${OUT_TMP_DIR}"/without-incentive-detail.txt.gz" ${DIR}"/ans/"${INPUT_DATE}"/"
    fi

    rm -r -f ${OUT_TMP_DIR}

    exit 0
else
    echo "PDI return code: " $?

    rm -r -f ${OUT_TMP_DIR}

    exit 1
fi
