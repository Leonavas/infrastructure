#!/bin/bash

if [ ! $# -eq 3 ]
then
    echo "Usage: ${0} <PRC_PID> <SOURCE_DIR> <OUTPUT_DIR>"
    exit 1
fi

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation

PRC_PID=${1}
UNP_DIR=${2}
OUT_DIR=${3}

CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD.csv

${PDI_BIN} -file="${DIR}"/pdi/job/recharge-data-aggregation.kjb -level=basic \
    "-param:acm.job.cfg.cn="${CN_CFG_FILE} \
    "-param:acm.job.dir.out="${OUT_DIR} \
    "-param:acm.job.dir.root="${DIR} \
    "-param:acm.job.dir.unp="${UNP_DIR} \
    "-param:acm.job.external.pid="${PRC_PID}
