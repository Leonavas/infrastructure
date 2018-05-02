#!/bin/bash

if [ $# -eq 3 ];
then
    SPLIT_CFG_FILE=${1}
    TODAY=${2} #TODAY=$(date +%Y%m%d)
    TOMORROW=${3} #TOMORROW=$(date --date="1 day" +%Y%m%d)
else
    echo "Usage: $0 <SPLIT_CONFIG> <TODAY: yyyyMMdd> <TOMORROW: yyyyMMdd>"
    exit 1
fi

#===============================================================
#   CONSTANTES
#===============================================================

PENTAHO_JAVA_HOME="/opt/openidea/programs/jdk1.8.0_65"
#PENTAHO_JAVA_HOME="/usr/lib/jvm/java-8-oracle"
export PENTAHO_JAVA_HOME

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-7.0.0.0-25/data-integration"
#KETTLE_HOME="/opt/inspiring/programs/pdi-ce-7.0.0.0-25/data-integration"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

HOME_DIR="$(cd "`dirname $0`/.." && pwd)"

JOB_FILE="run-split"

PID_FILE="${HOME_DIR}/var/pid"

LOG_LEVEL="Basic"

P_PID=$$

SRC_DIR=${HOME_DIR}"/out"
OUT_DIR=${HOME_DIR}"/split"

IN_PARAMS=" -param:acm.job.dir.in.mailing="${SRC_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.out="${OUT_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.mailing-split="${HOME_DIR}"/cfg/"${SPLIT_CFG_FILE}
IN_PARAMS="${IN_PARAMS} -param:acm.job.param.date1="${TODAY}
IN_PARAMS="${IN_PARAMS} -param:acm.job.param.date2="${TOMORROW}

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
        is_running=$(ps -ef | awk '{print "X"$2"X"}' | grep "X"${pid}"X")
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

function init(){
    checkPID

    setLogFile

    mkdir -p ${TMP_DIR} ${OUT_DIR}

}

function finalize(){
    rm -rf ${TMP_DIR} ${PID_FILE}
}


#===============================================================
#   Main
#===============================================================

init

${PDI_BIN} "-file=${HOME_DIR}/pdi/job/${JOB_FILE}.kjb" ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

finalize

exit $process_result

