#!/bin/bash

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/report/facebook"

EXT_DIR="/opt/openidea/acm/operator/claro/report/campaign-detailed-movement/rpt/201704/Fidelizacao/incentivo"

P_PID=$$

TMP_DIR=${DIR}"/tmp/"${P_PID}

mkdir -p ${TMP_DIR}

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/1-facebook.kjb -level=Basic \
     " -param:acm.job.dir.out="${DIR}"/out" \
     " -param:acm.job.dir.tmp="${TMP_DIR} \
     " -param:acm.job.dir.in.campaigns="${EXT_DIR} \
     " -param:acm.job.file.cfg.faixa-zb1="${DIR}"/cfg/faixa-zb1.csv" \
     " -param:acm.job.file.in.balance=/opt/openidea/acm/operator/claro/files/balance/balance_prepago_20170502.txt.gz"


rm -rf ${TMP_DIR}
