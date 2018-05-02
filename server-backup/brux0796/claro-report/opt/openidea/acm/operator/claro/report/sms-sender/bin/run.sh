#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================

if [ $# -ne 3 ];
then
    echo "Usage: $0 <MESSAGE_ID> <MESSAGE_FILENAME> <NTC_FILE_REGEX>"
    exit 1
fi

PENTAHO_JAVA_HOME="/opt/openidea/programs/jdk1.8.0_65"
#PENTAHO_JAVA_HOME="/usr/lib/jvm/java-8-oracle"
export PENTAHO_JAVA_HOME

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-7.0.0.0-25/data-integration"
#KETTLE_HOME="/opt/inspiring/programs/pdi-ce-7.0.0.0-25/data-integration"
export KETTLE_HOME
PDI_BIN=${KETTLE_HOME}"/kitchen.sh"

HOME_DIR="$(cd "`dirname $0`/.." && pwd)"

JOB_FILE="Run"

PID_FILE="${HOME_DIR}/var/pid"

LOG_LEVEL="Basic"

P_PID=$$

PROFILE_FILENAME=${HOME_DIR}"/cfg/claro_profile.properties"
MESSAGE_ID=${1}
MESSAGE_FILENAME=${HOME_DIR}"/msg/${2}"
NTC_FILE_REGEX=${3}
NDC_CFG="/opt/openidea/acm/operator/claro/report/common/src/DDD_v2.csv"
#NDC_CFG="/opt/inspiring/claro/jobs/producao/common/src/DDD_v2.csv"
TMP_DIR=${HOME_DIR}"/tmp/"${P_PID}

IN_PARAMS=" -param:message_filename="${MESSAGE_FILENAME}
IN_PARAMS="${IN_PARAMS} -param:message_id="${MESSAGE_ID}
IN_PARAMS="${IN_PARAMS} -param:ndc_cfg="${NDC_CFG}
IN_PARAMS="${IN_PARAMS} -param:ntc_dir="${HOME_DIR}"/src"
IN_PARAMS="${IN_PARAMS} -param:ntc_file_regex="${NTC_FILE_REGEX}
IN_PARAMS="${IN_PARAMS} -param:prc_dir="${HOME_DIR}"/prc"
IN_PARAMS="${IN_PARAMS} -param:process_id="${P_PID}
IN_PARAMS="${IN_PARAMS} -param:profile_filename="${PROFILE_FILENAME}
IN_PARAMS="${IN_PARAMS} -param:tmp_dir="${TMP_DIR}

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

${PDI_BIN} "-file=${HOME_DIR}/pdi/job/${JOB_FILE}.kjb" ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

rm -rf ${TMP_DIR} ${PID_FILE}

exit $process_result

