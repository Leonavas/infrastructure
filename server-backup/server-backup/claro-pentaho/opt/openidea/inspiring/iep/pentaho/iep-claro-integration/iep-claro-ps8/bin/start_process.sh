#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic
JOB_FILE=iep-claro-ps8-remove-duplicatas.kjb

#===============================================================
#   VARIAVEIS
#===============================================================
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
BG=0
DATA_REFERENCIA=$(date --date="-1 day" +%Y%m%d)
DIAS=2

#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [boh] [-l <NIVEL LOG>] [-d <DATA>] [-t <DIAS>]"
    echo "Executa processo de remocao de duplicatas dos arquivos PS8"
    echo " "
    echo " Opcoes:"
    echo "   -l Nivel do log ${LOG_LEVELS}. Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -d Define a data de referencia. Padrao: ontem"
    echo "   -t Define o numero de dias somados a data de referencia. Padrao: ${DIAS}"
    echo "   -b Executa o processo em background"
    echo "   -o Imprime o log em um arquivo, localizado na pasta ../log"
    echo "   -h Exibe ajuda"
    echo " "
    echo " Exemplos:"
    echo "   $0 -bo"
    echo "   $0 -bo -l Detailed -d 20170817 -t 2"
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
    LOG_FILE="${HOME_DIR}/log/iep-claro-ps8-remove-duplicatas_${now}.log"
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
    DATA_REFERENCIA=$(date --date="$1" +%Y%m%d)

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


# Cria a pasta tmp. se nao existir
mkdir -p "${HOME_DIR}/tmp"

#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts :d:t:l:boh opt; do
    case ${opt} in
        l)
            setLogLevel ${OPTARG}
            ;;
        d)
            get_date ${OPTARG}
            ;;
        t)
            DIAS=${OPTARG}
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

echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Executando job ${JOB_FILE}"
echo "Data de Referencia: ${DATA_REFERENCIA}"
echo "Dias (D+x): ${DIAS}"

IN_PARAMS="-param:iep.claro.ps8.date.referencia=${DATA_REFERENCIA}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.ps8.dias.adicionais=${DIAS}"

if [ $BG -eq 0 ];
then
    ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

    process_result=$?

    echo "Job ${JOB_FILE} executado. Resultado: $process_result"

    exit $process_result
else
    nohup ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL} > /dev/null &
    echo $! > "${PID_FILE}"
fi
