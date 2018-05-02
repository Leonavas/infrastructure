#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=run-process.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
PRC_DATE=$(date -u --date="-1 day" +%Y%m%d)

#===============================================================
#   FUNCOES
#===============================================================

#===============================================================
#
# Instrucoes de uso
#
#===============================================================
function usage()
{
   echo "Uso:"
   echo "$0 [OPTIONS]"
   echo "   -d <DATA>: Data atual, no formato YYYYMMDD, por exemplo, 20160621"
   echo "   -p <DATA>: Data passada, no formato YYYYMMDD, por exemplo, 20160620"
   echo "   -l <LEVEL>: Nivel de log $LOG_LEVELS"
   echo "   -o: Escreve saida no arquivo de log"
   echo "   -h: Exibe ajuda"
   echo " "
   echo "   Exemplos:"
   echo "      $0"
   echo "      $0 -d 20160621 -o"
   echo "      $0 -d 20160621 -p 20160619 -l Detailed -o"
   echo " "
} 

function validate_date()
{
    valid_date=$(date -u --date="$1" +%Y%m%d)
	
    if [ $? -ne 0 ];
    then
        echo "Formato de data invalido: $1"
	echo "Formato esperado: AAAAMMDD. Exemplo: 20160721"
        exit 1
    fi
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
	LOG_FILE="${HOME_DIR}/log/foto_saldo_${PRC_DATE}_${now}.log"
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

#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts :d:p:l:oh opt; do
    case ${opt} in
        d)
            PRC_DATE=${OPTARG}
            validate_date ${PRC_DATE}
            ;;
        p)
            PAST_DATE=${OPTARG}
            validate_date ${PAST_DATE}
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

if [ -z "$PAST_DATE" ];
then
    PAST_DATE=$(date -u --date="${PRC_DATE} -1 day" +%Y%m%d)

elif [ $PAST_DATE -ge $PRC_DATE ];
then
	echo "Data final deve ser maior que a data inicial"
	exit 1
fi

echo "Iniciando processamento de arquivo de foto de saldo"
echo "Comparando arquivo de ${PRC_DATE} com o de ${PAST_DATE}"

IN_PARAMS=" -param:iep.job.date.old=${PAST_DATE}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.date.process=${PRC_DATE}"


${PDI_BIN} "-file=${HOME_DIR}/pdi/job/${JOB_FILE}" ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

EXECUTION_RESULT=$?
echo "Processamento de arquivo de foto de saldo finalizado"
echo "Resultado da execucao: ${EXECUTION_RESULT}"

exit $EXECUTION_RESULT

