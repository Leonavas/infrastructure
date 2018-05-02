#!/bin/bash

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

P_PID=$$

DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation

SRC_DIR=${DIR}/rpt
OUT_DIR=${DIR}/rpt
TMP_DIR=${DIR}/tmp/${P_PID}

mkdir -p ${TMP_DIR}

${PDI_BIN} -file="${DIR}"/pdi/job/run-report-ndc-changes.kjb -level=Basic \
    "-param:acm.job.dir.out="${TMP_DIR} \
    "-param:acm.job.dir.src="${SRC_DIR} \
    "-param:acm.job.dir.tmp="${TMP_DIR}

function save_output() {

    __FILE=${1}
    __DESTINATION=${2}

    if [ -e ${__FILE} ]
    then
        mv ${__FILE} ${__DESTINATION}
    fi
}

save_output ${TMP_DIR}/changes-report-carrier.txt.gz ${OUT_DIR}/
save_output ${TMP_DIR}/changes-report-ddd.txt.gz ${OUT_DIR}/
save_output ${TMP_DIR}/changes-report-national.txt.gz ${OUT_DIR}/
save_output ${TMP_DIR}/full-report-carrier.txt.gz ${OUT_DIR}/
save_output ${TMP_DIR}/full-report-ddd.txt.gz ${OUT_DIR}/
save_output ${TMP_DIR}/full-report-national.txt.gz ${OUT_DIR}/

rmdir ${TMP_DIR}
