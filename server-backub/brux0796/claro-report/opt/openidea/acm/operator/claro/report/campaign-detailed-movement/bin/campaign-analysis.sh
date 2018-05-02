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

FILE_CFG_NDC="/opt/openidea/acm/operator/claro/report/common/src/DDD_v2.csv"
OUT_TMP_DIR=$DIR"/tmp/"$$
SORT_TMP_DIR=${OUT_TMP_DIR}"/sort"

mkdir -p ${OUT_TMP_DIR} ${SORT_TMP_DIR}

FILE_BASELINE="/opt/openidea/acm/operator/claro/files/state/"${INPUT_DATE}"01.txt.gz"

EXT_DATA_DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi/ext"
FILE_GCU=${EXT_DATA_DIR}"/universal_control_group.txt.gz"
FILE_PROCON=${EXT_DATA_DIR}"/uplift_optinout.txt.gz"

$PDI_BIN -file="$DIR"/pdi/job/campaign-analysis.kjb -level=basic \
    " -param:acm.job.cfg.file.ndc="${FILE_CFG_NDC} \
    " -param:acm.job.dir.out="${OUT_TMP_DIR} \
    " -param:acm.job.dir.sort="${SORT_TMP_DIR} \
    " -param:acm.job.dir.src.report="${DIR}"/rpt/"${INPUT_DATE} \
    " -param:acm.job.file.baseline="${FILE_BASELINE} \
    " -param:acm.job.file.gcu="${FILE_GCU} \
    " -param:acm.job.file.procon="${FILE_PROCON} \
> ${DIR}/log/campaign-analysis-${INPUT_DATE}.log 2>&1

if [ $? -eq 0 -o $? -eq 142 ]; then

    echo "PDI return code: " $?

    if [ -d ${DIR}"/ans/"${INPUT_DATE} ]; then
        rm -r -f ${DIR}"/ans/"${INPUT_DATE}
    fi

    mkdir -p ${DIR}"/ans/"${INPUT_DATE}

    mv ${OUT_TMP_DIR}"/"*.* ${DIR}"/ans/"${INPUT_DATE}"/"

    zip -mj9 ${DIR}"/ans/"${INPUT_DATE}"/incentivos-campanhas.zip" ${DIR}"/ans/"${INPUT_DATE}"/incentivos-campanhas.csv"

    echo "Resumo Incentivos ${INPUT_DATE}"|/bin/mail -s "Resumo incentivos campanhas" -a ${DIR}"/ans/"${INPUT_DATE}"/incentivos-campanhas.zip" e_rcluiz@stefanini.com
    
    mv ${OUT_TMP_DIR}/campaign-append.txt.gz ${DIR}"/ans/"${INPUT_DATE}/

    rm -r -f ${OUT_TMP_DIR}

    exit 0
else
    echo "PDI return code: " $?
    
    mv ${OUT_TMP_DIR}/campaign-append.txt.gz ${DIR}"/ans/"${INPUT_DATE}/

    rm -r -f ${OUT_TMP_DIR} 

    exit 1
fi
