#!/bin/bash

if [ ! $# -eq 6 ]
then
    echo "Usage: $0 <NEW_BALANCE_SNAPSHOT> <OFFER_OPTION_INPUT> <SCORE_ACTIVE_INPUT> <SCORE_ZB_INPUT> <TECHNOLOGY_SEGMENTATION_INPUT> <UNIVERSAL_CONTROL_GROUP_INPUT>"
    exit 1
fi

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi"

P_PID=$$

rm -rf ${DIR}"/tmp/"${P_PID}

TMP_DIR=${DIR}"/tmp/"${P_PID}
OUT_DIR=${DIR}"/out"

NEW_BALANCE_SNAPSHOT=$1
OFFER_OPTION_INPUT=$2
SCORE_ACTIVE_INPUT=$3
SCORE_ZB_INPUT=$4
TECHNOLOGY_SEGMENTATION_INPUT=$5
UNIVERSAL_CONTROL_GROUP_INPUT=$6

CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD.csv
PLAN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/plan_distribution.cfg

mkdir -p ${TMP_DIR}"/sort" ${TMP_DIR}"/out"

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/run-external-data-composite.kjb -level=Detailed \
     " -param:acm.job.dir.out="${OUT_DIR} \
     " -param:acm.job.dir.tmp.out="${TMP_DIR}"/out" \
     " -param:acm.job.dir.tmp.sort="${TMP_DIR}"/sort" \
     " -param:acm.job.file.cfg.ndc="${CN_CFG_FILE} \
     " -param:acm.job.file.cfg.plan="${PLAN_CFG_FILE} \
     " -param:acm.job.file.in.new_balance="${NEW_BALANCE_SNAPSHOT} \
     " -param:acm.job.file.in.offer_option="${OFFER_OPTION_INPUT} \
     " -param:acm.job.file.in.score_active="${SCORE_ACTIVE_INPUT} \
     " -param:acm.job.file.in.score_zb="${SCORE_ZB_INPUT} \
     " -param:acm.job.file.in.technology_segmentation="${TECHNOLOGY_SEGMENTATION_INPUT} \
     " -param:acm.job.file.in.universal_control_group="${UNIVERSAL_CONTROL_GROUP_INPUT}

#rm -rf ${TMP_DIR}


