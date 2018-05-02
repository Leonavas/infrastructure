#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=iep-claro-portout.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
REFERENCE_DATE=$(date)
START_DATE=$(date -d "$REFERENCE_DATE 119 mins ago" +"%d/%m/%Y %H:%M")
END_DATE=$(date -d "$REFERENCE_DATE" +"%d/%m/%Y %H:%M")
START_TIME=$(echo "$START_DATE" | cut -c12-16)
END_TIME=$(echo "$END_DATE" | cut -c12-16)
LOG_LEVEL=${DEFAULT_L:wqOG_LEVEL}
BG=0

echo "$START_DATE"
echo "$END_DATE"
echo "$START_TIME"
echo "$END_TIME"
#exit 1

#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [-borh] [-l <NIVEL_LOG>] [-d DATA INICIAL] HORA_INICIAL TAMANHO_JANELA"
    echo "Obtem os registros de portout e executa no IEP"
    echo "   PARAMETROS"
    echo "   HORA_INICIAL: Hora de inicio da janela, no formato HH:mm, exemplo, 08:00"
    echo "   TAMANHO_JANELA: Tamanho em MINUTOS da janela, exemplo, 90"
    echo "   OPCOES:"
    echo "   -d  Data de início da janela, no formato AAAAMMDD. Caso não informado considera o dia atual."
    echo "   -l  Determina o nivel do log: Error, Nothing, Minimal, Basic, Detailed, Debug ou Rowlevel. Padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -b  Executa o processo em background"
    echo "   -o  Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
    echo "   -h  Exibe ajuda"
    echo "   "
    echo "   Exemplos:"
    echo "      $0 08:00 90"
    echo "      $0 -o -d 20171020 -l Detailed"
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
    LOG_FILE="${HOME_DIR}/log/iep-claro-portout_${now}.log"
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
    REFERENCE_DATE=$(date --date="$1" +%Y-%m-%d)

    if [ $? -ne 0 ];
    then
        echo "Formato de data invalido: $1"
        echo "Formato esperado: AAAAMMDD. Exemplo: 20160721"
        exit 1
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
while getopts :d:l:boh opt; do
    case ${opt} in
        d)
            get_date ${OPTARG}
            ;;
        l)
            setLogLevel ${OPTARG}
            ;;
        b)
            BG=1
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

#if [ $# -ne 2 ];
#then
#    usage
#    exit 1
#fi

echo "Janela: [${START_DATE}, $END_DATE{}]"
echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Executando job ${JOB_FILE}"

IN_PARAMS="-param:iep.claro.portout.param.date.start=${START_DATE}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.portout.param.date.end=${END_DATE}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.portout.param.time.start=${START_TIME}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.portout.param.time.end=${END_TIME}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.portout.param.iep.url=${IEP_CLARO_URL}"

if [ $BG -eq 0 ];
then
    ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

    process_result=$?

    echo "Job ${JOB_FILE} executado. Resultado: $process_result"

    exit $process_result
else
    nohup ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL} > /dev/null &
fi
