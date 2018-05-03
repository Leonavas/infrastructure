#!/bin/bash

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi"

OUT_DIR=${DIR}"/out"
PRC_DIR=${DIR}"/prc"

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/run-update-all.kjb -level=Basic \
     " -param:acm.job.dir.in="${OUT_DIR} \
     " -param:acm.job.dir.prc="${PRC_DIR} \
     " -param:acm.job.file.name.regex=update_[0-9]{1,}\.txt\.gz"
