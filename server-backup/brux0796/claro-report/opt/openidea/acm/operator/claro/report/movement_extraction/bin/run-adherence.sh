#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================

PENTAHO_JAVA_HOME="/opt/openidea/programs/jdk1.8.0_65"
export PENTAHO_JAVA_HOME

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-7.0.0.0-25/data-integration/"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

HOME_DIR="$(cd "`dirname $0`/.." && pwd)"

JOB_FILE="run-adherences"

PID_FILE="${HOME_DIR}/var/pid"

LOG_LEVEL="Basic"

EXT_CFG_DIR=${HOME_DIR}/../common/src

OUT_DIR=${HOME_DIR}"/rpt/adh"
SRC_DIR=${HOME_DIR}"/out"
TMP_DIR=${HOME_DIR}"/tmp/"$$
FILE_CFG_ACTION=${EXT_CFG_DIR}"/action_value.csv"
FILE_CFG_BONUS=${EXT_CFG_DIR}"/bonus-ngp.csv"
FILE_CFG_DDD=${EXT_CFG_DIR}"/DDD_v2.csv"
FILE_CFG_STATE_TRANSITION=${EXT_CFG_DIR}"/full-state-transition-map.csv"

#===============================================================
#   Functions
#===============================================================
function setLogFile()
{
    # cria diretorio, caso nao exista
    mkdir -p "${HOME_DIR}/log"
    
    # define arquivo de log
    now=$(date +%Y%m%d%H%M%S)
    LOG_FILE="${HOME_DIR}/log/${JOB_FILE}_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
    echo "Arquivo de log: ${LOG_FILE}"
    echo "Log level: ${LOG_LEVEL}"
}

function checkPID()
{   
    if [ -f "${PID_FILE}" ];
    then
        pid=$(head -n 1 ${PID_FILE})
        is_running=$(ps -ef | awk '{print "x"$2"x"}' | grep "x"${pid}"x")
        if [ -n "${is_running}" ];
        then
            echo "Proccess already running with pid ${pid}."
            exit 1
        fi
    else
        mkdir -p "${HOME_DIR}/var"
    fi
    
    echo $$ > "$PID_FILE"
}

#===============================================================
#   Main
#===============================================================
checkPID

setLogFile

mkdir -p ${TMP_DIR} ${OUT_DIR}

IN_PARAMS=" -param:acm.job.dir.out="${OUT_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.src="${SRC_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.tmp="${TMP_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.action-value="${FILE_CFG_ACTION}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.bonus="${FILE_CFG_BONUS}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.ndc="${FILE_CFG_DDD}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.state-transition-map="${FILE_CFG_STATE_TRANSITION}

${PDI_BIN} "-file=${HOME_DIR}/pdi/job/${JOB_FILE}.kjb" ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

rm -rf ${TMP_DIR} ${PID_FILE}

exit $process_result

