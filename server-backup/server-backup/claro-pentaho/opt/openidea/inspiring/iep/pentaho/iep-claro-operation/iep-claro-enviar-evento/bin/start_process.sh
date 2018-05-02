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
JOB_FILE=iep-claro-enviar-evento.kjb
BG=0
FORCE_START=0

#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [-bosh] [-l <NIVEL>] [-e EVENTO] [-a ATTRS]"
    echo "Inicia o processamento de eventos"
    echo
    echo "OPCOES:"
    echo "  -e    Nome do evento"
    echo "  -a    Lista de atributos, separados por ,(virgula). Formato: Atributo=Valor"
    echo "  -l    Nivel do log (Error Nothing Minimal Basic Detailed Debug Rowlevel). Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "  -b    Executa o processo em background"
    echo "  -s    Executa o processo apenas uma vez"
    echo "  -o    Imprime o log em um arquivo, localizado na pasta ./log"
    echo "  -h    Exibe ajuda"
    echo
    echo "   Exemplos:"
    echo "      $0 -o -e EnviarSMS -a CodigoSms=SMS001,SendSyncSms=true"
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
    LOG_FILE="${HOME_DIR}/log/iep-claro-enviar-evento_${now}.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
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
    IEP_CLARO_URL="http://localhost:8082"
fi

#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts :e:a:l:boh opt; do
    case ${opt} in
        e)
            NOME_EVENTO=${OPTARG}
            ;;
        a)
            ATRIBUTOS_EVENTO=${OPTARG}
            ;;
        l)
            setLogLevel ${OPTARG}
            ;;
        b)
            BG=1
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


echo "Nivel de log: ${LOG_LEVEL}"
echo "Arquivo de log: ${LOG_FILE}"
echo "Executando job ${JOB_FILE}"
echo "Nome do Evento: ${NOME_EVENTO}"
echo "Atributos: ${ATRIBUTOS_EVENTO}"

IN_PARAMS="-param:iep.claro.enviar.eventos.param.iep.url=${IEP_CLARO_URL}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.enviar.eventos.param.atributos.evento=${ATRIBUTOS_EVENTO}"
IN_PARAMS="${IN_PARAMS} -param:iep.claro.enviar.eventos.param.nome.evento=${NOME_EVENTO}"


if [ $BG -eq 0 ];
then
    ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}

    process_result=$?

    echo "Job ${JOB_FILE} executado. Resultado: $process_result"

    exit $process_result
else
    nohup ${IEP_CLARO_PDI_BIN} "-file="${HOME_DIR}"/pdi/job/"${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL} > /dev/null &
fi

