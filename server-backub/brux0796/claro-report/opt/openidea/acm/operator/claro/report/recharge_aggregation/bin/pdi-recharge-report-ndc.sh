#!/bin/bash

if [ $# -eq 1 ]
then
    IN_REP_DATE=$(date --date="${1}" +%Y%m%d)
else
    IN_REP_DATE=$(date --date="1 days ago" +%Y%m%d)
fi

echo "REP_DATE="${IN_REP_DATE}

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation

SRC_DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation/out
OUT_DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation/rpt

CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD_v2.csv

${PDI_BIN} -file="${DIR}"/pdi/job/run-report-ndc.kjb -level=Minimal \
    "-param:acm.job.cfg.cn="${CN_CFG_FILE} \
    "-param:acm.job.date.processing="${IN_REP_DATE} \
    "-param:acm.job.dir.out="${OUT_DIR} \
    "-param:acm.job.dir.src="${SRC_DIR}
