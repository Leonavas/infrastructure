#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
JOB_FILE=atualizar-entrada.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic

#===============================================================
#   VARIAVEIS
#===============================================================
FILE_DATE="$(date +%Y%m)01" #YYYYMMDD
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
GET_FROM_SRC_DIR="Y"
WRITE_TO_LOG=0
QUIET=0
PID_FILE="${HOME_DIR}/var/pid"

#===============================================================
#   FUNCOES
#===============================================================

#===============================================================
#
# Imprime instrucoes de uso
#
#===============================================================
function usage()
{
    echo "Uso: $0 [OPCOES]"
    echo "Executa o processo de Habito de Consumo. Caso nao seja utilizada a opcao -s,"
    echo " obtem os arquivos do diretorio configurado no arquivo ${HOME_DIR}/cfg/config.properties"
    echo " "
    echo "   OPCOES:"
    echo "   -d <Data>     Data de processamento, no formato AAAAMMDD. Caso nao informado considera o primeiro dia do mes atual"
    echo "   -l <NIVEL>    Nivel do log ${LOG_LEVELS}. Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -o    Imprime o log em um arquivo, localizado na pasta ${HOME_DIR}/log"
    echo "   -s    Obtem o arquivo de entrada da pasta ${HOME_DIR}/src"
    echo "   -q    Nao exibe a saida do Pentaho                                "
    echo "   -h    Exibe ajuda"
    echo "   "
    echo "   Exemplos:"
    echo "      $0 -d 20160701"
    echo "      $0 -d 20160701 -l Detailed -o"
}

#===============================================================
#
# Valida a data de entrada
#
#===============================================================
function get_date()
{
    FILE_DATE=$(date --date="$1" +%Y%m%d)

    if [ $? -ne 0 ];
    then
        echo "Formato de data invalido: $1"
        echo "Formato esperado: AAAAMMDD. Exemplo: 20160701"
        exit 1
    fi

}

#===============================================================
#
# Valida o nivel de log
#
#===============================================================
function setLogLevel()
{
    if [[ " ${LOG_LEVELS[@]} " =~ " $1 " ]]; then
        LOG_LEVEL=$1
    else
        echo "Nivel de log invalido: $1"
        exit 1
    fi
}

#===============================================================
#
# Define o arquivo de log
#
#===============================================================
function setLogFile()
{
    # cria diretorio, caso nao exista
    mkdir -p "${HOME_DIR}/log"
    
    # define arquivo de log
    now=$(date +%Y%m%d%H%M%S)
    LOG_FILE="${HOME_DIR}/log/habito-consumo_${FILE_DATE}_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
}

#===============================================================
#
# Verifica se ja existe um processo rodando
#
#===============================================================
function checkPID()
{   
    if [ -f "$PID_FILE" ];
    then
        pid=$(head -n 1 $PID_FILE)
        is_running=$(ps -ef | awk '{print $2}' | grep $pid)
        if [ -n "$is_running" ];
        then
            echo "Ja existe um processo rodando com o pid $pid"
            exit 1
        fi
    else
        mkdir -p "${HOME_DIR}/var"
    fi
    
    echo $$ > "$PID_FILE"
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
while getopts :d:l:soqh opt; do
    case ${opt} in
        d)
            get_date ${OPTARG}
            ;;
        l)
            setLogLevel ${OPTARG}
            ;;
        s)
            GET_FROM_SRC_DIR="Y"
            ;;
        o)
            WRITE_TO_LOG=1
            ;;
        q)
            QUIET=1
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

if [ $WRITE_TO_LOG -eq 1 ];
then
    setLogFile
fi

echo "Data de referencia: ${FILE_DATE}"
echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Executando job ${JOB_FILE}"

IN_PARAMS="-param:iep.job.file_date=${FILE_DATE}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.url=${IEP_CLARO_URL}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.file.get_from_src=${GET_FROM_SRC_DIR}"

if [ $QUIET -eq 0 ];
then
    ${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}
else
    ${PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL} >> /dev/null
fi 

process_result=$?

echo "Job ${JOB_FILE} executado. Resultado: $process_result"


exit $process_result
