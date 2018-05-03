#!/bin/bash

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi"

PRC_DIR=${DIR}"/out/balance_analysis"

CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD_v2.csv

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/balance-analysis.kjb -level=Basic \
     " -param:acm.job.dir.in="${PRC_DIR} \
     " -param:acm.job.file.cfg.ndc="${CN_CFG_FILE}
