#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=iep-claro-optout.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
FILE_DATE=$(date -u +%Y%m%d) #YYYYMMDD
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
BG=0

#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [-borh] [-d <DATA>] [-p <DATA>] [-l <NIVEL LOG>]"
    echo "Processa arquivos de optout"
    echo "   OPCOES:"
    echo "   -d  Data de processamento, no formato AAAAMMDD. Caso nao informado considera o dia atual"
    echo "   -p  Data passada, no formato YYYYMMDD. Caso nao informado considera o arquivo processado mais recente"
    echo "   -l  Determina o nivel do log: Error, Nothing, Minimal, Basic, Detailed, Debug ou Rowlevel. Padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -r  Reenvia eventos para o IEP dos arquivos da pasta ${HOME_DIR}/rpr"
    echo "   -b  Executa o processo em background"
    echo "   -o  Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
    echo "   -h  Exibe ajuda"
    echo "   "
    echo "   Exemplos:"
    echo "      $0 -d 20160709"
    echo "      $0 -d 20160709 -l Detailed -o"
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
    LOG_FILE="${HOME_DIR}/log/iep-claro-optout_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
}

function checkPID()
{
    PID_FILE=${HOME_DIR}/var/pid

    if [ -f "$PID_FILE" -a `pgrep -F ${PID_FILE}|wc -l` -gt 0 ];
    then
        echo "Ja existe um processo executando"
        exit 1
    else
        mkdir -p "${HOME_DIR}/var"
    fi

    echo $$ > "$PID_FILE"
}

function get_date()
{
    PARSED_DATE=$(date -u --date="$1" +%Y%m%d)

    if [ $? -ne 0 ];
    then
        echo "Formato de data invalido: $1"
        echo "Formato esperado: AAAAMMDD. Exemplo: 20160721"
        exit 1
    fi

}

function get_last_file_date()
{
    OLD_FILE_DATE=$(date -u --date="$FILE_DATE -1 day" +%Y%m%d)

    MOST_RECENT_FILE=$(ls -r prc/ | head -n1)
    if [ -n "${MOST_RECENT_FILE}" ];
    then
        OLD_FILE_DATE=${MOST_RECENT_FILE:7:8}
    fi 
}

#===============================================================
#   MAIN SCRIPT
#===============================================================

# Verifica se ja existe algum processo em execucao
checkPID

if [ ! -f "$IEP_CLARO_PDI_BIN" ];
then
    echo "A variavel de ambiente IEP_CLARO_PDI_BIN nao esta definida"
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
while getopts :d:p:l:borh opt; do
    case ${opt} in
        d)
            get_date ${OPTARG}
            FILE_DATE=${PARSED_DATE}
            ;;
        p)
            get_date ${OPTARG}
            OLD_FILE_DATE=${PARSED_DATE}
            ;;
        l)
            setLogLevel ${OPTARG}
            ;;
        b)
            BG=1
            ;;
        r)
            JOB_FILE="iep-claro-optout-reprocessa.kjb"
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

if [ -z "$OLD_FILE_DATE" ];
then
    get_last_file_date
fi

if [ $FILE_DATE -le $OLD_FILE_DATE ];
then
    echo "Data de referencia ($FILE_DATE) deve ser superior a data anterior ($OLD_FILE_DATE)"
    exit 1
fi

echo "Data de referencia: ${FILE_DATE}"
echo "Data anterior: ${OLD_FILE_DATE}"
echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Executando job ${JOB_FILE}"

IN_PARAMS="-param:iep.claro.optout.param.date.old=${OLD_FILE_DATE}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.optout.param.date.reference=${FILE_DATE}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.optout.param.iep.url=${IEP_CLARO_URL}"

if [ $BG -eq 0 ];
then
    ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

    process_result=$?

    echo "Job ${JOB_FILE} executado. Resultado: $process_result"

    exit $process_result
else
    nohup ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL} > /dev/null &
fi
