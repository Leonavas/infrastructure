#!/bin/bash

if [ $# -eq 1 ]
then
    IN_REP_DATE=$1
else
    IN_REP_DATE=$(date +%Y%m)
fi

echo "REP_DATE="${IN_REP_DATE}

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation

SRC_DIR=${DIR}/rpt
OUT_DIR=${DIR}/ibps
TMP_DIR=${DIR}/tmp/$$

rm -rf ${OUT_DIR}

mkdir -p ${TMP_DIR} ${OUT_DIR}

IN_PARAMS="-param:acm.job.dir.out=${OUT_DIR}"
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.src=${SRC_DIR}"
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.tmp=${TMP_DIR}"
IN_PARAMS="${IN_PARAMS} -param:acm.job.param.month=${IN_REP_DATE}"

${PDI_BIN} -file="${DIR}"/pdi/job/ibps-metric-generation.kjb -level=Minimal ${IN_PARAMS}

rm -rf ${TMP_DIR}

REMOTE_DIR="/opt/openidea/inspiring/ibps/pentaho"

ssh acm@brux0793 'source /home/acm/.bash_profile;rm -f /opt/openidea/inspiring/ibps/pentaho/recharge_uplift/src/uplift*.gz'
scp ${DIR}/unp/uplift*.txt acm@brux0793:${REMOTE_DIR}/recharge_uplift/src/
ssh acm@brux0793 'source /home/acm/.bash_profile;/bin/gzip /opt/openidea/inspiring/ibps/pentaho/recharge_uplift/src/uplift*.txt'

scp ${DIR}/ibps/hora/report-ddd-*.gz acm@brux0793:${REMOTE_DIR}/recharge_uplift_backoffice/src/ddd/
scp ${DIR}/ibps/hora/report-carrier-*.gz acm@brux0793:${REMOTE_DIR}/recharge_uplift_backoffice/src/region/
scp ${DIR}/ibps/hora/report-national-*.gz acm@brux0793:${REMOTE_DIR}/recharge_uplift_backoffice/src/total/
scp ${DIR}/ibps/dia/report-carrier-*.gz acm@brux0793:${REMOTE_DIR}/recharge_uplift_backoffice/src/region_day/
scp ${DIR}/ibps/dia/report-national-* acm@brux0793:${REMOTE_DIR}/recharge_uplift_backoffice/src/total_day/

