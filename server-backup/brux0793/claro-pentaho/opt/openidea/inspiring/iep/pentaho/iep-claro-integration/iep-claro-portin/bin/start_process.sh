#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=iep-claro-portin.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
REFERENCE_DATE=$(date +%Y%m%d) #YYYYMMDD
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
BG=0

#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [-borh] [-l <NIVEL_LOG>] [-d DATA INICIAL] HORA_INICIAL TAMANHO_JANELA"
    echo "Obtem os registros de portin e executa no IEP"
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
    LOG_FILE="${HOME_DIR}/log/iep-claro-portin_${now}.log"
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

function get_window_start()
{
    
    WINDOW_START=$(date --date="${REFERENCE_DATE} $1"  +"%Y-%m-%dT%H:%M":01)
    
    if [ $? -ne 0 ];
    then
        echo "Formato de hora invalido: $1"
        echo "Formato esperado: HH:mm. Exemplo: 08:00"
        exit 1
    fi
}

function get_window_end()
{

    WINDOW_SIZE=$2
    if [[ ! $WINDOW_SIZE =~ ^[0-9]+$ ]]
    then
        echo "Tamanho da janela invalido: $WINDOW_SIZE. Somente numeros sao aceitos"
        exit 1
    fi
    
    WINDOW_START_IN_SEC=$(date --date="${REFERENCE_DATE} $1" +%s)
    WINDOW_SIZE_IN_SEC=$(( WINDOW_SIZE * 60 ))
    WINDOW_END_TS=$(( WINDOW_START_IN_SEC + WINDOW_SIZE_IN_SEC ))
    WINDOW_END=$(date --date @$WINDOW_END_TS +"%Y-%m-%dT%H:%M":00)
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

if [ $# -ne 2 ];
then
    usage
    exit 1
fi

get_window_start $1
get_window_end $1 $2

echo "Data de referencia: ${REFERENCE_DATE}"
echo "Janela: [${WINDOW_START}, ${WINDOW_END}]"
echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Executando job ${JOB_FILE}"

IN_PARAMS="-param:iep.claro.portin.param.date.start=${WINDOW_START}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.portin.param.date.end=${WINDOW_END}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.portin.param.iep.url=${IEP_CLARO_URL}"

if [ $BG -eq 0 ];
then
    ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

    process_result=$?

    echo "Job ${JOB_FILE} executado. Resultado: $process_result"

    exit $process_result
else
    nohup ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL} > /dev/null &
fi
