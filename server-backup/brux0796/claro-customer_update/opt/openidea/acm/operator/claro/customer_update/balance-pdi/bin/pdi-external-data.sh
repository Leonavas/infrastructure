#!/bin/bash

if [ ! $# -eq 1 ]
then
    echo "Usage: $0 <P_PID>"
    exit 1
fi

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi"

P_PID=$1

TMP_DIR=${DIR}"/tmp/"${P_PID}
EXT_DIR=${DIR}"/ext"

CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD.csv

mkdir -p ${TMP_DIR}"/out" ${TMP_DIR}"/sort"

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/external-data-composite.kjb -level=Basic \
     " -param:acm.job.dir.ext="${EXT_DIR} \
     " -param:acm.job.dir.tmp.out="${TMP_DIR}"/out" \
     " -param:acm.job.dir.tmp.sort="${TMP_DIR}"/sort" \
     " -param:acm.job.file.cfg.ndc="${CN_CFG_FILE} 

#rm -rf ${TMP_DIR}

