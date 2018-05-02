#!/bin/bash

# Verifica as variaveis de ambiente
if [ ! -f "$PDI_BIN" ] || [ ! -d "$IEP_PENTAHO_HOME" ];
then
    echo "A variavel de ambiente PDI_BIN ou PENTAHO_HOME nao esta definida"
    exit 1
fi

# Carrega script com funcoes comuns
source $IEP_PENTAHO_HOME/common/sh/common.sh

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=evento-com-data-de-aprovisionamento_job.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS GLOBAIS
#===============================================================
PID_FILE="${HOME_DIR}/var/pid"
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
WRITE_LOG=0

#===============================================================
#   FUNCOES
#===============================================================

#===============================================================
#
# Exibe instrucoes de uso
#
#===============================================================
function usage()
{
    echo "Uso: $0 [OPCOES]"
    echo "   OPCOES:"
    echo "   -l <NIVEL>    Nivel do log ${LOG_LEVELS}. Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -o    Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
    echo "   -h    Exibe ajuda"
    echo "   "
    echo "   Exemplos:"
    echo "      $0"
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
    LOG_FILE="${HOME_DIR}/log/evento-com-data-de-aprovisionamento_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
}
#===============================================================
#   MAIN SCRIPT
#===============================================================

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

checkPID $PID_FILE

now=$(date -u +%Y%m%d%H%M%S)
today=$(date -u +%Y%m%d)
today_process_yesterday=$(date -u -d"1 days ago" +%Y%m%d)
if [ $WRITE_LOG -eq 1 ];
then
    setLogFile
fi

echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Data de referencia: ${now}"
echo "Data de Hoje: ${today}"
echo "Data de execução da foto de saldo: ${today_process_yesterday}"
echo "Executando job ${JOB_FILE}"

IN_PARAMS="${IN_PARAMS} -param:iep.job.url=${IEP_CLARO_URL}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.date.reference=${now}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.date.yesterday=${today_process_yesterday}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.date.today=${today}"

${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

rm $PID_FILE

exit $process_result
