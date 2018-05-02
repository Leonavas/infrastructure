#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=process_mailing.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )


#===============================================================
#   VARIAVEIS
#===============================================================
LOG_LEVEL=Basic


#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [OPTIONS]"
	echo "   OPCOES:"
	echo "   -c <Nome da Campanha>: Nome da campanha configurada no IEP"
	echo "   -f <ARQUIVO>: Arquivo de entrada. Deve estar na pasta ${HOME_DIR}/src"
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
	LOG_FILE="${HOME_DIR}/log/mailing_${now}.log"
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
while getopts :c:f:l:o opt; do
    case ${opt} in
        c)  
            CAMPAIGN_NAME=${OPTARG}
			IN_PARAMS="${IN_PARAMS} -param:iep.job.campaign=${CAMPAIGN_NAME}"
			echo "Campanha: $CAMPAIGN_NAME"
            ;;
        f)
            INPUT_FILE=${OPTARG}
			IN_PARAMS="${IN_PARAMS} -param:iep.job.file.input=${INPUT_FILE}"
			echo "Arquivo de entrada: $INPUT_FILE"
            ;;
        l)
			setLogLevel ${OPTARG}
			;;
		o)
			setLogFile
			;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
			usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

echo "Executando job ${JOB_FILE}"

IN_PARAMS="${IN_PARAMS} -param:iep.job.url=${IEP_CLARO_URL}"

${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"

exit $process_result

