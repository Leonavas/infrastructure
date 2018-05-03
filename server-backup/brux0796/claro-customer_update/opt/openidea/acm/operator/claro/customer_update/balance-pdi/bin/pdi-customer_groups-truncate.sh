#!/bin/bash

if [ ! $# -eq 0 ]
then
    echo "Usage: $0"
    exit 1
fi

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi"

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/customer_groups-truncate.kjb -level=Basic \
     " -param:acm.job.dir.root="${DIR} \
     " -param:acm.job.param.consumer_nr=1" \
     " -param:acm.job.param.total_consumers=1"

#rm -rf ${TMP_DIR}

