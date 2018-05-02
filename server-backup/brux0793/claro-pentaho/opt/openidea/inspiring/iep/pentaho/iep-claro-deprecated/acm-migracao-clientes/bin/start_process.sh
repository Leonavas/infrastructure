#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=acm-migracao-clientes.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
WRITE_LOG=0

#===============================================================
#   FUNCOES
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
    LOG_FILE="${HOME_DIR}/log/${FILENAME}_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
}

function getFileName()
{
	FILENAME_WITH_EXTENSION=$(basename $1)
	FILENAME=$(echo ${FILENAME_WITH_EXTENSION} | sed 's/\.txt\.gz//g')
}

function executeJob()
{
    getFileName $1

	if [ $WRITE_LOG -eq 1 ];
	then
	    setLogFile
	fi

	echo "Nivel de log: ${LOG_LEVEL}"
    echo "Arquivo de log: ${LOG_FILE}"	
    echo "Arquivo processado: ${FILENAME}"
	echo "Executando job ${JOB_FILE}"
    
    IN_PARAMS="-param:iep.job.url=${IEP_CLARO_URL}"
	IN_PARAMS="${IN_PARAMS} -param:iep.job.filename=${FILENAME}"
    
    
    ${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}
    
    JOB_RESULT=$?
    
    echo "Job ${JOB_FILE} executado. Resultado: $JOB_RESULT"
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

# Executa para todos os arquivos do diretorio src
for file in ${HOME_DIR}/src/*.txt.gz
do
    executeJob $file
done
