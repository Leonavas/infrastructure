#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=iep-claro-pacotes-ngp-contratacao.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
FILE_DATE=$(date +%Y%m%d%H) #YYYYMMDDHH
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
GET_FROM_SRC_DIR="N"
BG=0

#===============================================================
#   FUNCOES
#===============================================================
function get_date()
{
    FILE_DATE=$(date --date="$1" +%Y%m%d%H)

    if [ $? -ne 0 ];
    then
        echo "Formato de data invalido: $1"
        echo "Formato esperado: AAAAMMDDHH. Exemplo: 2016072116"
        exit 1
    fi

}

function usage()
{
    echo "Uso: $0 [-borsh] [-d <DATA>] [-l <NIVEL LOG>]"
    echo "Processa arquivo com contratacao dos pacotes NGP"
    echo "   OPCOES:"
    echo "   -d  Data de processamento, no formato AAAAMMDDHH. Caso nao informado considera o dia e horario atuais"
    echo "   -l  Determina o nivel do log: Error, Nothing, Minimal, Basic, Detailed, Debug ou Rowlevel. Padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -r  Reenvia eventos para o IEP dos arquivos da pasta ${HOME_DIR}/rpr"
    echo "   -b  Executa o processo em background"
    echo "   -o  Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
    echo "   -s  Obtem o arquivo de entrada da pasta ${HOME_DIR}/src"
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
    LOG_FILE="${HOME_DIR}/log/iep-claro-pacotes-ngp-contratacao_${now}.log"
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
while getopts :d:l:borsh opt; do
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
        r)
            JOB_FILE="iep-claro-pacotes-ngp-contratacao-reprocessa.kjb"
            ;;
        s)
            GET_FROM_SRC_DIR="Y"
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

echo "Data de referencia: ${FILE_DATE}"
echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Executando job ${JOB_FILE}"

IN_PARAMS="-param:iep.claro.pacotes.ngp.contratacao.param.date.reference=${FILE_DATE}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.pacotes.ngp.contratacao.param.get.from.src=${GET_FROM_SRC_DIR}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.pacotes.ngp.contratacao.param.iep.url=${IEP_CLARO_URL}"

if [ $BG -eq 0 ];
then
    ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

    process_result=$?

    echo "Job ${JOB_FILE} executado. Resultado: $process_result"

    exit $process_result
else
    nohup ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL} > /dev/null &
fi
