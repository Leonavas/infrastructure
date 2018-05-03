#!/bin/bash

if [ ! $# -eq 4 ]
then
    echo "Usage: $0 <P_PID> <NEW_BALANCE_SNAPSHOT> <OLD_LAST_ACTIVE_DATE> <NEW_LAST_ACTIVE_DATE>"
    exit 1
fi

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi"

P_PID=$1

TMP_DIR=${DIR}"/ext/last_active_date/tmp/"${P_PID}

NEW_BALANCE_SNAPSHOT=$2
OLD_LAST_ACTIVE_DATE=$3
NEW_LAST_ACTIVE_DATE=$4

CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD_v2.csv
PLAN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/plan_distribution.cfg

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/last-active-date-file-parser.kjb -level=Basic \
     " -param:acm.job.dir.tmp.sort="${TMP_DIR} \
     " -param:acm.job.file.cfg.ndc="${CN_CFG_FILE} \
     " -param:acm.job.file.cfg.plan="${PLAN_CFG_FILE} \
     " -param:acm.job.file.in.last_active_date="${OLD_LAST_ACTIVE_DATE} \
     " -param:acm.job.file.in.new_balance="${NEW_BALANCE_SNAPSHOT} \
     " -param:acm.job.file.out.last_active_date="${NEW_LAST_ACTIVE_DATE} 

exit $?
