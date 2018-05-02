#!/bin/bash

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/report/recharge_aggregation"

IN_DIR=${DIR}"/out"
OUT_DIR=${DIR}"/out"

CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD.csv

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/recharge-aggregation.kjb -level=Basic \
     " -param:acm.job.file.cfg.ndc="${CN_CFG_FILE} \
     " -param:acm.job.dir.in="${IN_DIR} \
     " -param:acm.job.dir.out="${OUT_DIR} > ${DIR}/log/ercharge_aggregation.log

