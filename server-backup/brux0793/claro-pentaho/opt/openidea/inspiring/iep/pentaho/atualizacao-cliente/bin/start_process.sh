#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=atualizacao_cliente.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
FILE_DATE=$(date -u --date='-1 day' +%Y%m%d) #YYYYMMDD

#===============================================================
#   FUNCOES
#===============================================================
function get_date()
{
    FILE_DATE=$(date -u --date="$1" +%Y%m%d)

    if [ $? -ne 0 ];
    then
        echo "Formato de data invalido: $1"
        echo "Formato esperado: AAAAMMDD. Exemplo: 20160721"
        exit 1
    fi

}

function usage()
{
    echo "Uso: $0 [OPCOES]"
    echo "   OPCOES:"
    echo "   -d <Data>: Data de processamento, no formato AAAAMMDD. Caso nao informado considera o dia anterior"
    echo "   -l <NIVEL>: Nivel do log (Error, Nothing, Minimal, Basic, Detailed, Debug ou Rowlevel). Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -o Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
	echo "   -h Exibe ajuda"
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
    LOG_FILE="${HOME_DIR}/log/atualizacao-cliente_${FILE_DATE}_${now}.log"
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

# Se o endereco do IEP nao estiver definido, usao o valor padrao
if [ -z "$IEP_CLARO_URL" ];
then
    IEP_CLARO_URL="http://localhost:8082"
fi

#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts :d:l:oh opt; do
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
            echo "Opcao invalida: -$OPTARG" >&2
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

echo "Executando job ${JOB_FILE}"
echo "Data de referencia: ${FILE_DATE}"

IN_PARAMS="-param:iep.job.url=${IEP_CLARO_URL}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.file_date=${FILE_DATE}"


${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

exit $process_result

