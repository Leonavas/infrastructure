#!/bin/bash

if [ $# -eq 1 ];
then
    INPUT_DATE=$1 # "18 Oct 2015 GMT-3" Fuso horário + horário de verao

    PROCESS_DATE=$(date --date="$INPUT_DATE" +%Y%m%d) #YYYYMMDD
else
    PROCESS_DATE=$(date --date="1 days ago" +%Y%m%d) #YYYYMMDD
fi

PENTAHO_JAVA_HOME="/opt/openidea/programs/jdk1.8.0_65"
export PENTAHO_JAVA_HOME
KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-7.0.0.0-25/data-integration/"
#KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

DIR=/opt/openidea/acm/operator/claro/report/movement_extraction

CFG_DIR=/opt/openidea/acm/operator/claro/report/common/src

SORT_TMP_DIR=$DIR"/tmp/"$$

mkdir -p ${SORT_TMP_DIR}

FILE_STATE_TRANSITION_MAP=${CFG_DIR}/full-state-transition-map.csv
FILE_REMOVE_ACTION=${CFG_DIR}/remove-action.csv
FILE_ACTION=${CFG_DIR}/action_value.csv
FILE_NDC=${CFG_DIR}/DDD_v2.csv

MONTHES_BACK=8

$PDI_BIN -file="$DIR"/pdi/job/MovementSegmentation.kjb -level=basic \
    " -param:acm.job.dir.in="$DIR"/out" \
    " -param:acm.job.dir.out="$DIR"/tmp" \
    " -param:acm.job.dir.sort="${SORT_TMP_DIR} \
    " -param:acm.job.file.cfg.action="${FILE_ACTION} \
    " -param:acm.job.file.cfg.ndc="${FILE_NDC} \
    " -param:acm.job.file.cfg.remove-action="${FILE_REMOVE_ACTION} \
    " -param:acm.job.file.cfg.state-transition-map="${FILE_STATE_TRANSITION_MAP} \
    " -param:acm.job.param.monthes_back="${MONTHES_BACK} \
    " -param:acm.job.param.process_date="$PROCESS_DATE
	
rm -rf ${SORT_TMP_DIR}

if [ -f $DIR"/tmp/movimento-campanha.zip" ]; then
    echo "Base Campanhas - ${PROCESS_DATE}"|/bin/mail -a $DIR"/tmp/movimento-campanha.zip" -s "Movimento Campanhas CSV" kcseno@stefanini.com

fi

