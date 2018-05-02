#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=segmentacao-tecnologia.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
FILE_DATE=$(date -u +%Y%m%d) #YYYYMMDD
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
WRITE_TO_LOG=false

#===============================================================
#   FUNCOES
#===============================================================
function get_old_file_date()
{
    # Se a data foi passada, valida
    if [ -n "$1" ];
	then
	    OLD_FILE_DATE=$(date -u --date="$1" +%Y%m%d)
	    if [ $? -ne 0 ];
        then
            echo "Formato de data invalido: $1"
            echo "Formato esperado: AAAAMMDD. Exemplo: 20160721"
            exit 1
        else
		    return
		fi
    fi
	
	# Se a data nao foi encontrada, tenta encontrar o arquivo mais antigo
	most_recent_file=$(ls -t ${HOME_DIR}/processed/technology_segmentation_[0-9]*\.txt\.gz | head -n1)
	
	if [ -z "$most_recent_file" ];
	then
	    echo "Nenhum arquivo anterior encontrado na pasta ${HOME_DIR}/processed"
		exit 1
	fi

	OLD_FILE_DATE=$(echo $most_recent_file | grep -o "2[0-9]*")
	
	if [ -z "$OLD_FILE_DATE" ];
	then
	    echo "Nao foi possivel determinar a data do ultimo arquivo processado"
		echo "Verifique o diretorio ${HOME_DIR}/processed"
		exit 1
	fi
}

function usage()
{
    echo "Uso: $0 [OPCOES]"
    echo "   OPCOES:"
	echo "   -p <Data>     Data do ultimo arquivo, no formato AAAAMMDD. Caso nao informado, obtem o arquivo mais recente"
    echo "   -l <NIVEL>    Nivel do log ${LOG_LEVELS}. Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -o    Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
    echo "   -h    Exibe ajuda"
    echo "   "
    echo "   Exemplos:"
	echo "      $0 -p 20160709 -l Detailed -o"
    echo "      $0 -l Detailed -o"
	echo "      $0 -o"
	echo "      $0"
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
    LOG_FILE="${HOME_DIR}/log/technology_segmentation_${FILE_DATE}_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
	echo "Arquivo de log: ${LOG_FILE}"
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
while getopts :d:p:t:l:soh opt; do
    case ${opt} in
		p)
		    OLD_FILE_DATE=${OPTARG}
		    ;;
        l)
            setLogLevel ${OPTARG}
            ;;
        o)
            WRITE_TO_LOG=true
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

get_old_file_date ${OLD_FILE_DATE}

if [ "$WRITE_TO_LOG" = true ];
then
    setLogFile
fi

echo "Data de referencia: ${FILE_DATE}"
echo "Data anterior: ${OLD_FILE_DATE}"
echo "Nivel de log: ${LOG_LEVEL}"
echo "Executando job ${JOB_FILE}"

IN_PARAMS="-param:iep.job.date.file_date=${FILE_DATE}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.date.old_file_date=${OLD_FILE_DATE}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.url=${IEP_CLARO_URL}"

${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

exit $process_result

