#!/bin/bash

if [ $# -eq 1 ];
then
    INPUT_DATE=$1 # "18 Oct 2015 GMT-3" Fuso horário + horário de verao

    PARTITION_DATE_D1=$(date --date="${INPUT_DATE}" +%Y%m%d) #YYYYMMDD
    PARTITION_DAY_D1=$(date --date="${INPUT_DATE}" +%-j) #Day of the year
    PARTITION_DATE_D0=$(date --date="${INPUT_DATE} 1 days" +%Y%m%d) #YYYYMMDD
else
    echo "Usage $0 <PROCESS_DATE: 18 Oct 2015 GMT-3>"
    exit 1
fi

PENTAHO_JAVA_HOME="/opt/openidea/programs/jdk1.8.0_65"
export PENTAHO_JAVA_HOME
KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-7.0.0.0-25/data-integration/"
#KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

DIR=/opt/openidea/acm/operator/claro/report/campaign-detailed-movement

P_PID=$$

TMP_DIR=${DIR}/tmp/${P_PID}

rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}

$PDI_BIN -file=${DIR}/pdi/job/Extract.kjb -level=basic \
    " -param:acm.job.dir.tmp="${TMP_DIR} \
    " -param:acm.job.partition_d0="${PARTITION_DATE_D0} \
    " -param:acm.job.partition_d1="${PARTITION_DATE_D1} \
> ${DIR}/log/extract-${PARTITION_DATE_D1}-P${PARTITION_DAY_D1}.log


if [ $? -eq 0 -o $? -eq 142 ]; then

    echo "PDI return code: " $?

    if [ -d ${DIR}"/out/"${PARTITION_DATE_D1} ]; then
        rm -rf ${DIR}"/out/"${PARTITION_DATE_D1}
    fi

    mv -f -u ${TMP_DIR}/${PARTITION_DATE_D1} ${DIR}/out
    rm -rf ${TMP_DIR}
    exit 0
else
    echo "PDI return code: " $?

    rm -r ${OUT_TMP_DIR}
    echo FAIL
    exit 1
fi



