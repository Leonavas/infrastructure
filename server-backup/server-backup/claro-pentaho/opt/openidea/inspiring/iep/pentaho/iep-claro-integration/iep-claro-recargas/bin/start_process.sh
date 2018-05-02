#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
JOB_FILE=iep-claro-recargas-processar-loop.kjb
BG=0
FORCE_START=0

#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [-bfosh] [-l <NIVEL>]"
    echo "Inicia o processamento de arquivos de recarga da Claro. Execucao em loop e a padrao"
    echo
    echo "OPCOES:"
    echo "  -l    Nivel do log (Error Nothing Minimal Basic Detailed Debug Rowlevel). Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "  -f    Forca o inicio do processo. Se estiver um processo executando, para o processo"
    echo "  -b    Executa o processo em background"
    echo "  -s    Executa o processo apenas uma vez"
    echo "  -o    Imprime o log em um arquivo, localizado na pasta ./log"
    echo "  -h    Exibe ajuda"
    echo
    echo "   Exemplos:"
    echo "      $0 -so"
    echo "      $0 -bo"
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
    LOG_FILE="${HOME_DIR}/log/iep-claro-recargas_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}  -maxloglines=50000 -maxlogtimeout=10"
}

function forceStart()
{
    CTL_FILE="${HOME_DIR}/var/executing"
    STOP_FILE="${HOME_DIR}/var/stop"
    COUNTER=0

    if [ -f "$CTL_FILE"  ];
    then
        echo "Ja ha um processo em execucao, parando processo"
        touch $STOP_FILE
        echo "Aguardando o processo parar por, no maximo, 5 minutos"
    fi

    while [ -f "$STOP_FILE"  ] && [ $COUNTER -lt 10 ]; do
        sleep 30
        COUNTER=$(( COUNTER + 1 ))
    done

    if [ $COUNTER -eq 10 ]; then
        echo "Nao foi possivel iniciar o processo, parar manualmente"
        exit 1
    fi

}

#===============================================================
#   MAIN SCRIPT
#===============================================================

if [ ! -f "$IEP_CLARO_PDI_BIN" ];
then
    echo "A variavel de ambiente IEP_CLARO_PDI_BIN nao esta definida"
    exit 1
fi

# Se o endereco do IEP nao estiver definido, usao o valor padrao
if [ -z "$IEP_CLARO_URL" ];
then
    IEP_CLARO_URL="http://localhost:8076"
fi

#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts :l:bsfoh opt; do
    case ${opt} in
        l)
            setLogLevel ${OPTARG}
            ;;
        b)
            BG=1
            ;;
        s)
            JOB_FILE=iep-claro-recargas-processar-single.kjb
            ;;
        f)
            FORCE_START=1
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


if [ $FORCE_START -eq 1 ];
then
    forceStart
fi

echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Executando job ${JOB_FILE}"

IN_PARAMS="-param:iep.claro.recargas.iep.url=${IEP_CLARO_URL}"

if [ $BG -eq 0 ];
then
    ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

    process_result=$?

    echo "Job ${JOB_FILE} executado. Resultado: $process_result"

    exit $process_result
else
    nohup ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL} > /dev/null &
fi

