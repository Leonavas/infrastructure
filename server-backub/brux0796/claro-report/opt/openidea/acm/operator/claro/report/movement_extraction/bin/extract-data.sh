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

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

DIR=/opt/openidea/acm/operator/claro/report/movement_extraction

P_PID=$$

TMP_DIR=${DIR}/tmp/${P_PID}

rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}

$PDI_BIN -file=${DIR}/pdi/job/Extract.kjb -level=basic \
    " -param:acm.job.dir.tmp="${TMP_DIR} \
    " -param:acm.job.partition_d0="${PARTITION_DATE_D0} \
    " -param:acm.job.partition_d1="${PARTITION_DATE_D1} > ${DIR}/log/extract-${PARTITION_DATE_D1}-P${PARTITION_DAY_D1}.log

if [ -f ${TMP_DIR}/Base_Campanhas_${PARTITION_DATE_D1}.txt ]
then
    mv ${TMP_DIR}/Base_Campanhas_${PARTITION_DATE_D1}.txt ${TMP_DIR}/Base_Campanhas_${PARTITION_DATE_D1}_P${PARTITION_DAY_D1}.txt
    gzip ${TMP_DIR}/Base_Campanhas_${PARTITION_DATE_D1}_P${PARTITION_DAY_D1}.txt
    mv ${TMP_DIR}/Base_Campanhas_${PARTITION_DATE_D1}_P${PARTITION_DAY_D1}.txt.gz ${DIR}/out/
    rm -rf ${TMP_DIR} 
else
    rm -rf ${TMP_DIR}
fi
