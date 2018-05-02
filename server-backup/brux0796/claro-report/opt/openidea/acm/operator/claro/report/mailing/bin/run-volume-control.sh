#!/bin/bash

if [ $# -eq 3 ];
then
    VOLUME_CFG_FILE=${1}
    LEFTOVER_CFG_FILE=${2}
    MAILING_DATE=${3} #MAILING_DATE=$(date +%Y%m%d)
else
    echo "Usage: $0 <VOLUME_CFG_FILE> <LEFTOVER_CFG_FILE> <DATA-MAILING - yyyyMMdd>"
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

JOB_FILE="run-mailing-volume-control"

PID_FILE="${HOME_DIR}/var/pid"

LOG_LEVEL="Basic"

P_PID=$$

TMP_DIR=${HOME_DIR}"/tmp/"${P_PID}
SRC_DIR=${HOME_DIR}"/split"
OUT_DIR=${HOME_DIR}"/trunc"

FIXED_MAILING=${HOME_DIR}"/cfg/fixed-mailing"
MAILING_LEFTOVER_FILENAME=${HOME_DIR}"/cfg/"${LEFTOVER_CFG_FILE}
MAILING_VOLUME_FILENAME=${HOME_DIR}"/cfg/"${VOLUME_CFG_FILE}

IN_PARAMS=" -param:acm.job.dir.cfg.fixed-mailing="${FIXED_MAILING}
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.in.mailing="${SRC_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.out="${OUT_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.tmp="${TMP_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.mailing-leftover="${MAILING_LEFTOVER_FILENAME}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.mailing-volume="${MAILING_VOLUME_FILENAME}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.out.volume="${HOME_DIR}"/trunc/Volumetria_"${MAILING_DATE}".txt"
IN_PARAMS="${IN_PARAMS} -param:acm.job.param.date="${MAILING_DATE}

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

