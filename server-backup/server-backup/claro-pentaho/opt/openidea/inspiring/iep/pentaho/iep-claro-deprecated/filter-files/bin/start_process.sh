#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=transfer-files-main.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
FILE_SERVER=localhost
FILE_TYPE=local
FILTER_TYPE=NO_FILTER
FILTER_VALUE=NONE
OUTPUT_FOLDER="${HOME_DIR}/out"
LOG_LEVEL=${DEFAULT_LOG_LEVEL}

#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [OPCOES] [FILTRO] VALOR_FILTRO"
    echo "   OPCOES:"
    echo "   -f <Arquivo>    Caminho do arquivo que sera filtrado"
    echo "   -d <Dir>        Diretorio onde o arquivo filtrado sera gerado"
    echo "   -s <Server>     Servidor de origem do arquivo, caso seja um arquivo remoto"
    echo "   -l <Nivel>      Nivel do log (Error Nothing Minimal Basic Detailed Debug Rowlevel). Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -o    Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
    echo "   -h    Exibe ajuda"
    echo "   "
    echo "   FILTRO:"
    echo "   -e <REGEX>     Filtra por expressao regular"
    echo "   -m <MOD>       Filtra pela funcao MOD(MSISDN, X)=0"
    echo "   -c <CN>        Filtra pelo CN (DDD)"
    echo "   -u <UF>        Filtra pela UF (Estado)"
    echo "   -r <REGIAO>    Filtra pela Regiao"
    echo "   "
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
    LOG_FILE="${HOME_DIR}/log/filter_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
}


#===============================================================
#   MAIN SCRIPT
#===============================================================
if [ ! -f "$PDI_BIN" ];
then
    echo "A variavel de ambiente PDI_BIN nao esta definida"
    exit 1
fi

function check_flag()
{
    if [ -z "$filter_flag" ];
    then 
        echo "Escolha apenas uma opcao de filtro: [emcur]"
        exit 1
    fi
}

#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts :f:s:e:m:c:u:r:d:l:o opt; do
    case ${opt} in
        f)  
            FILENAME=${OPTARG}
            FILE_DIR=$(dirname ${OPTARG})
            ;;
        s)  
            FILE_SERVER=${OPTARG}
            FILE_TYPE=remote
            ;;
        e)
            check_flag
            filter_flag=e
            FILTER_TYPE="REGEX"
            FILTER_VALUE=${OPTARG}
            ;;
        m)
            check_flag
            filter_flag=m
            FILTER_TYPE="MOD"
            FILTER_VALUE=${OPTARG}
            ;;
        c)
            check_flag
            filter_flag=c
            FILTER_TYPE="CN"
            FILTER_VALUE=${OPTARG}
            ;;
        u)
            check_flag
            filter_flag=u
            FILTER_TYPE="ESTADO"
            FILTER_VALUE=${OPTARG}
            ;;
        r)
            check_flag
            filter_flag=r
            FILTER_TYPE="REGIAO"
            FILTER_VALUE=${OPTARG}
            ;;
        d)
            OUTPUT_FOLDER=${OPTARG}
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
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

if [ ! -f "${FILENAME}" ];
then
    echo "Arquivo de entrada nao encontrado"
    exit 1
fi

echo "Filtro: $FILTER_TYPE"
echo "Valor do Filtro: $FILTER_VALUE"
echo "Arquivo: ${FILENAME}"
echo "Servidor: ${FILE_SERVER}"
echo "Tipo: ${FILE_TYPE}"
echo "Diretorio de Saida: ${OUTPUT_FOLDER}"
echo "Executando job ${JOB_FILE}"


IN_PARAMS="${IN_PARAMS} -param:iep.job.dir.source=${FILE_DIR}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.file_server=${FILE_SERVER}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.file_type=${FILE_TYPE}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.filename=${FILENAME}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.filter_type=${FILTER_TYPE}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.filter_value=${FILTER_VALUE}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.output_folder=${OUTPUT_FOLDER}"

${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

exit $process_result
