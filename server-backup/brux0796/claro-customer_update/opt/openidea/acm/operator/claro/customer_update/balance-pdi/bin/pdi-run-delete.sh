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
PRC_DIR=${DIR}"/prc/"${P_PID}

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/generic-db-processor.kjb -level=Minimal \
     " -param:acm.job.dir.in="${TMP_DIR}"/out/delete" \
     " -param:acm.job.dir.prc="${PRC_DIR} \
     " -param:acm.job.file.name.regex=delete_without_campaign_[0-9]+_[0-9]+\.txt\.gz" \
     " -param:acm.job.param.command=delete"

#rm -rf ${TMP_DIR}

