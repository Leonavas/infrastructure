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

CFG_DIR=/opt/openidea/acm/operator/claro/report/common/src

OUT_TMP_DIR=$DIR"/tmp/"$$

mkdir -p ${OUT_TMP_DIR}

FILE_STATE_TRANSITION_MAP=${CFG_DIR}/full-state-transition-map.csv
FILE_REMOVE_ACTION=${CFG_DIR}/remove-action.csv
FILE_ACTION=${CFG_DIR}/action_value.csv

$PDI_BIN -file="$DIR"/pdi/job/parse-files.kjb -level=basic \
    " -param:acm.job.dir.out="${OUT_TMP_DIR} \
    " -param:acm.job.dir.src.prefix="${INPUT_DATE} \
    " -param:acm.job.dir.src.root="${DIR}"/out" \
    " -param:acm.job.dir.tmp="${OUT_TMP_DIR} \
    " -param:acm.job.file.cfg.action="${FILE_ACTION} \
    " -param:acm.job.file.cfg.remove-action="${FILE_REMOVE_ACTION} \
    " -param:acm.job.file.cfg.state-transition-map="${FILE_STATE_TRANSITION_MAP} \
> ${DIR}/log/parse-files-${INPUT_DATE}.log 2>&1

if [ $? -eq 0 -o $? -eq 142 ]; then

    echo "PDI return code: " $?

    if [ -d ${DIR}"/rpt/"${INPUT_DATE} ]; then
        rm -r -f ${DIR}"/rpt/"${INPUT_DATE}
    fi

    mkdir -p ${DIR}"/rpt/"${INPUT_DATE}

    mv ${OUT_TMP_DIR}"/"* ${DIR}"/rpt/"${INPUT_DATE}"/"

    rm -r -f ${OUT_TMP_DIR}

    exit 0
else
    echo "PDI return code: " $?

    rm -r -f ${OUT_TMP_DIR}

    exit 1
fi
