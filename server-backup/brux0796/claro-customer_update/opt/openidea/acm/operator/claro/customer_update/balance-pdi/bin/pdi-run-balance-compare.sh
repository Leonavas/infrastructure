#!/bin/bash

if [ ! $# -eq 3 ]
then
    echo "Usage: $0 <P_PID> <PRC_DATE> <NEW_BALANCE_SNAPSHOT>"
    exit 1
fi

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi"

P_PID=$1

TMP_DIR=${DIR}"/tmp/"${P_PID}
EXT_DIR=${DIR}"/ext"
PRC_DIR=${DIR}"/prc/"${P_PID}

PRC_DATE=$2
NEW_BALANCE_SNAPSHOT=$3
TOTAL_INSTANCES=4

CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD.csv
PLAN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/plan_distribution.cfg

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/run-balance-compare.kjb -level=Basic \
     " -param:acm.job.date.process="${PRC_DATE} \
     " -param:acm.job.dir.ext="${EXT_DIR} \
     " -param:acm.job.dir.prc="${PRC_DIR} \
     " -param:acm.job.dir.root="${DIR} \
     " -param:acm.job.dir.tmp.out="${TMP_DIR}"/out" \
     " -param:acm.job.dir.tmp.sort="${TMP_DIR}"/sort" \
     " -param:acm.job.file.cfg.ndc="${CN_CFG_FILE} \
     " -param:acm.job.file.cfg.plan="${PLAN_CFG_FILE} \
     " -param:acm.job.file.in.new_balance="${NEW_BALANCE_SNAPSHOT} \
     " -param:acm.job.param.total_instances="${TOTAL_INSTANCES}

#rm -rf ${TMP_DIR}

