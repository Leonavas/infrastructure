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

PID_FILE="${HOME_DIR}/var/pid_1dia"

LOG_LEVEL="Basic"

EXT_CFG_DIR="/opt/openidea/acm/operator/claro/report/common/src"
BLACKLIST_DIR="/opt/openidea/acm/operator/claro/report/black_list/out"
BALANCE_DIR="/opt/openidea/acm/operator/claro/files/balance"
MAILING_ESPECIAL="/opt/openidea/acm/operator/claro/report/mailing/mailing_especial"
SRC_ROOT_DIR="/opt/openidea/acm/operator/claro/report/campaign-detailed-movement/out"

OUT_DIR=${HOME_DIR}"/out_1dia"
TMP_DIR=${HOME_DIR}"/tmp_1dia/"$$
FILE_CFG_ACTION=${EXT_CFG_DIR}"/action_value.csv"
FILE_CFG_REMOVE_ACTION=${EXT_CFG_DIR}"/remove-action.csv"
FILE_CFG_STATE_TRANSITION=${EXT_CFG_DIR}"/full-state-transition-map.csv"
FILE_CFG_DDD_GROUP=${HOME_DIR}"/cfg/ddd-group.csv"
FILE_CFG_MAILING=${HOME_DIR}"/cfg/mailing_1dia.csv"
PARAM_DAYS_AGO="2"

rm /opt/openidea/acm/operator/claro/report/mailing/out_1dia/*txt

for file in $(ls -ltrh ${BLACKLIST_DIR}"/DeviceCompatibilityTable_"*".csv.gz"|awk '{print $9}');
do 
    FILE_IN_DEVICE_COMPATIBILITY=${file}
done

ONE_DAY_AGO=$(date -d '10:00:00 1 days ago' +%Y%m%d)
TWO_DAYS_AGO=$(date -d '10:00:00 2 days ago' +%Y%m%d)

if [ -e ${BALANCE_DIR}"/balance_prepago_${ONE_DAY_AGO}.txt.gz" ]; 
then
    FILE_IN_BALANCE=${BALANCE_DIR}"/balance_prepago_${ONE_DAY_AGO}.txt.gz"
else
    if [ -e ${BALANCE_DIR}"/balance_prepago_${TWO_DAYS_AGO}.txt.gz" ]; 
    then
        FILE_IN_BALANCE=${BALANCE_DIR}"/balance_prepago_${TWO_DAYS_AGO}.txt.gz"
    fi
fi

if [ "x"${FILE_IN_BALANCE} = "x" ];
then
    echo "Job ${JOB_FILE} nao executado. Arquivo com dados de saldo dos clientes nao encontrado."
    exit 1
fi

#===============================================================
#   Functions
#===============================================================
function setLogFile()
{
    # cria diretorio, caso nao exista
    mkdir -p "${HOME_DIR}/log"
    
    # define arquivo de log
    now=$(date +%Y%m%d%H%M%S)
    LOG_FILE="${HOME_DIR}/log/${JOB_FILE}_1dia_${now}.log"
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

#===============================================================
#   Main
#===============================================================
checkPID

setLogFile


mkdir -p ${TMP_DIR} ${OUT_DIR}

IN_PARAMS=" -param:acm.job.dir.out="${OUT_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.src.root="${SRC_ROOT_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.tmp="${TMP_DIR}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.action="${FILE_CFG_ACTION}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.ddd-group="${FILE_CFG_DDD_GROUP}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.mailing="${FILE_CFG_MAILING}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.remove-action="${FILE_CFG_REMOVE_ACTION}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.cfg.state-transition-map="${FILE_CFG_STATE_TRANSITION}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.in.balance="${FILE_IN_BALANCE}
IN_PARAMS="${IN_PARAMS} -param:acm.job.file.in.device-compatibility="${FILE_IN_DEVICE_COMPATIBILITY}
IN_PARAMS="${IN_PARAMS} -param:acm.job.param.days-ago="${PARAM_DAYS_AGO}

${PDI_BIN} "-file=${HOME_DIR}/pdi/job/${JOB_FILE}.kjb" ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

rm -rf ${TMP_DIR} ${PID_FILE}

#rm ${MAILING_ESPECIAL}/in/muito*
#mv ${OUT_DIR}/muito* ${MAILING_ESPECIAL}/in/

#${MAILING_ESPECIAL}/bin/start_process.sh

#mv ${MAILING_ESPECIAL}/out/* ${OUT_DIR}


exit $process_result

