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

JOB_FILE="run"

PID_FILE="${HOME_DIR}/var/pid"

LOG_LEVEL="Basic"

BALANCE_DIR="/opt/openidea/acm/operator/claro/files/balance"
SRC_ROOT_DIR="/opt/openidea/acm/operator/claro/recharge/processed"

OUT_DIR=${HOME_DIR}"/out"
TMP_DIR=${HOME_DIR}"/tmp/"$$

ONE_DAY_AGO=$(date -d '10:00:00 1 days ago' +%Y%m%d)
TWO_DAYS_AGO=$(date -d '10:00:00 2 days ago' +%Y%m%d)
FILE_IN_BALANCE_NEW=${BALANCE_DIR}"/balance_prepago_${ONE_DAY_AGO}.txt.gz"
FILE_IN_BALANCE_OLD=${BALANCE_DIR}"/balance_prepago_${TWO_DAYS_AGO}.txt.gz"

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
        is_running=$(ps -ef | awk '{print $2}' | grep ${pid})
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
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.src.recharge="${SRC_ROOT_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.tmp="${TMP_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.in.balance.new="${FILE_IN_BALANCE_NEW}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.in.balance.old="${FILE_IN_BALANCE_OLD}

${PDI_BIN} "-file=${HOME_DIR}/pdi/job/${JOB_FILE}.kjb" ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

rm -rf ${TMP_DIR} ${PID_FILE}

exit $process_result

