#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=ibps-metric-generation.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS GLOBAIS
#===============================================================
PID_FILE="${HOME_DIR}/var/pid"
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
WRITE_LOG=0
QUIET=0

#===============================================================
#   FUNCOES
#===============================================================

#===============================================================
#
# Imprime instrucoes de uso
#
#===============================================================
function usage()
{
    echo "Uso: $0 [OPCOES]..."
    echo "Executa o processo do Pentaho que gera as metricas a serem enviadas  "
    echo "ao IBPS.                                                             "
    echo "   OPCOES:                                                           "
    echo "   -l <NIVEL>    Nivel do log. Valor padrao: ${DEFAULT_LOG_LEVEL}    "
    echo "   -o    Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
    echo "   -d    Data utilizada para filtrar os valor das metrias: YYYYMM    "
    echo "   -q    Nao exibe a saida do Pentaho                                "
    echo "   -h    Exibe ajuda                                                 "
    echo "                                                                     "
    echo "   Exemplos:                                                         "
    echo "      $0 -o                                                          "
    echo "      $0 -d 201701                                                   "
}


#===============================================================
#
# Define nível de log
#
#===============================================================
function setLogLevel()
{
    if [[ " ${LOG_LEVELS[@]} " =~ " $1 " ]]; then
        LOG_LEVEL=$1
    else
        echo "Nivel de log invalido: $1"
        exit 1
    fi
}


#===============================================================
#
# Define arquivo de log
#
#===============================================================
function setLogFile()
{
    # cria diretorio, caso nao exista
    mkdir -p "${HOME_DIR}/log"
    
    # define arquivo de log
    LOG_FILE="${HOME_DIR}/log/metrica-ibps_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
}

#===============================================================
#
# Verifica se ja existe um processo rodando
#
#===============================================================
function checkPID()
{   
    if [ -f "$PID_FILE" ];
    then
        pid=$(head -n 1 $PID_FILE)
        is_running=$(ps -ef | awk '{print $2}' | grep $pid)
        if [ -n "$is_running" ];
        then
            echo "Ja existe um processo rodando com o pid $pid"
            exit 1
        fi
    else
        mkdir -p "${HOME_DIR}/var"
    fi
    
    echo $$ > "$PID_FILE"
}

#===============================================================
#
# Executa o job
#
#===============================================================
function executeJob()
{
    started_at=$(date +%s)
    now=$(date +%Y%m%d%H%M%S)
      
    if [ $WRITE_LOG -eq 1 ];
    then
    	setLogFile
    fi

    P_PID=$$

    TMP_DIR=${HOME_DIR}/tmp/${P_PID}

    mkdir -p ${TMP_DIR}
    
    IN_PARAMS="-param:acm.job.dir.out=${HOME_DIR}/ibps"
    IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.src=${HOME_DIR}/rpt"
    IN_PARAMS="${IN_PARAMS} -param:acm.job.dir.tmp=${TMP_DIR}"
    IN_PARAMS="${IN_PARAMS} -param:acm.job.param.month=${FILTER_MONTH}"

    echo "Executando job ${JOB_FILE}"
    
    if [ $QUIET -eq 0 ];
    then
        ${PDI_BIN} -listparam "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}
    else
        ${PDI_BIN} -listparam "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL} >> /dev/null
    fi 
    
    process_result=$?
    
    echo "Job ${JOB_FILE} executado. Resultado: $process_result"
    
    finished_at=$(date +%s)

    rm -rf ${TMP_DIR}
    
    return $process_result
}

#===============================================================
#   MAIN SCRIPT
#===============================================================

if [ ! -f "$PDI_BIN" ];
then
    echo "A variavel de ambiente PDI_BIN nao esta definida"
    exit 1
fi

#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts :t:l:pqouh opt; do
    case ${opt} in
        l)
            setLogLevel ${OPTARG}
            ;;
        d)
            FILTER_MONTH=${OPTARG}
            ;;
        q)
            QUIET=1
            ;;
        o)
            WRITE_LOG=1
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Opcao invalida: -$OPTARG" >&2
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

checkPID

executeJob

echo "Processo de extracao de metricas finalizado"
