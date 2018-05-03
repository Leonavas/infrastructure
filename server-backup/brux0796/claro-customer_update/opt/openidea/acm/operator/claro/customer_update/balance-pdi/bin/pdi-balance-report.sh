#!/bin/bash

if [ ! $# -eq 3 ]
then
    echo "Usage: $0 <in.balance> <in.blacklist> <out.report>"
    exit 1
fi

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi"

P_PID=$$

TMP_DIR=${DIR}"/tmp/"${P_PID}

mkdir -p ${TMP_DIR}

CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD_v2.csv

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/balance-report.kjb -level=Basic \
     " -param:acm.job.dir.tmp="${TMP_DIR} \
     " -param:acm.job.file.cfg.ndc="${CN_CFG_FILE} \
     " -param:acm.job.file.in.balance="${1} \
     " -param:acm.job.file.in.blacklist="${2} \
     " -param:acm.job.file.out.report="${3}

rm -rf ${TMP_DIR}
