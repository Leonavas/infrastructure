#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=atualiza-arquivo-audit.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
FILE_DATE=$(date --date='-1 hour' +%Y-%m-%d_%H) #YYYY-MM-DD_HH

#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [OPCOES]"
    echo "   OPCOES:"
    echo "   -d <DATA>         Data de execucao. Valor padrao e a data atual"
    printf "   -l <LEVEL>        Nivel de log ( "; printf "%s " ${LOG_LEVELS[@]}; echo ")"
    echo "   -o    Escreve saida no arquivo de log"
    echo "   -h    Exibe ajuda"
    echo "   Exemplos:"
    echo "      $0 -d 2016-07-09_11 -i ./src"
    echo "      $0 -d 2016-07-09_11"
    echo "      $0 -i ./src"
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
    LOG_FILE="${HOME_DIR}/log/correcao-auditoria_${FILE_DATE}_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
}

function get_date()
{
    INPUT_DATE=$(echo $1 | sed s/-//g | sed s/_/" "/g)
    FILE_DATE=$(date --date="$INPUT_DATE" +%Y-%m-%d_%H)

    if [ $? -ne 0 ];
    then
        echo "Formato de data invalido: $1"
        echo "Formato esperado: AAAAMMDDHH. Exemplo: 2016072115"
        exit 1
    fi

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
while getopts :d:i:l:oh opt; do
    case ${opt} in
        d)  
            get_date ${OPTARG}
            ;;
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
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

echo "Data de referencia: $FILE_DATE"
echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"

echo "Executando job ${JOB_FILE}"

IN_PARAMS="${IN_PARAMS} -param:iep.job.url=${IEP_CLARO_URL}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.date.reference=${FILE_DATE}"


${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

exit $process_result

