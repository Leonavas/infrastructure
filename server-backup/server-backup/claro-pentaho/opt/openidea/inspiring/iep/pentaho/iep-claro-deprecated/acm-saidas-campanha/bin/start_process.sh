#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=acm-saidas-campanha.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
PID_FILE="${HOME_DIR}/var/pid"
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
GET_FROM_SRC_DIR="N"

#===============================================================
#   FUNCOES
#===============================================================

function usage()
{
    echo "Uso: $0 [OPCOES]"
    echo "   OPCOES:"
    echo "   -l <NIVEL>    Nivel do log ${LOG_LEVELS}. Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -o    Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
    echo "   -s    Obtem o arquivo de entrada da pasta ${HOME_DIR}/src"
    echo "   -h    Exibe ajuda"
    echo "   "
    echo "   Exemplos:"
    echo "      $0 -l Detailed -o"
}

function setLogLevel()
{
    if [[ " ${LOG_LEVELS[@]} " =~ " $1 " ]]; then
        LOG_LEVEL=$1
    else
        echo "Nivel de log invalido: $1"
        exit 1
    fi
}

function setLogFile()
{
    # cria diretorio, caso nao exista
    mkdir -p "${HOME_DIR}/log"
    
    # define arquivo de log
    now=$(date +%Y%m%d%H%M%S)
    LOG_FILE="${HOME_DIR}/log/acm-saidas-campanha_${now}.log"
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
#   MAIN SCRIPT
#===============================================================

if [ ! -f "$PDI_BIN" ];
then
    echo "A variavel de ambiente PDI_BIN nao esta definida"
    exit 1
fi

# Se o endereco do IEP nao estiver definido, usao o valor padrao
if [ -z "$IEP_CLARO_URL" ];
then
    IEP_CLARO_URL="http://localhost:8082"
fi

#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts :l:oh opt; do
    case ${opt} in
        l)
            setLogLevel ${OPTARG}
            ;;
        o)
            setLogFile
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

echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Executando job ${JOB_FILE}"

IN_PARAMS="${IN_PARAMS} -param:iep.job.url=${IEP_CLARO_URL}"


${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

JOB_RESULT=$?

rm ${PID_FILE}

echo "Job ${JOB_FILE} executado. Resultado: $JOB_RESULT"

