#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`" && pwd)"
JOB_FILE=send-mail.kjb
LOG_LEVELS=( Error Nothing Minimal Basic Detailed Debug Rowlevel )
DEFAULT_LOG_LEVEL=Basic
DEFAULT_SENDER_ADDRESS="$(whoami)@$(hostname)"
DEFAULT_SENDER=$(whoami)

#===============================================================
#   VARIAVEIS GLOBAIS
#===============================================================
LOG_LEVEL=${DEFAULT_LOG_LEVEL}
WRITE_LOG=0
sender_address=${DEFAULT_SENDER_ADDRESS}
sender=${DEFAULT_SENDER}

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
    echo "Uso: $0 -s ASSUNTO -d DESTINATARIOS -t TEXTO  [OPCOES]...            "
    echo "Envia e-mail                                                         "
    echo "                                                                     "
    echo "   OPCOES:                                                           "
    echo "   -a <ANEXO>         Envia anexo                                    "
    echo "   -s <ASSUNTO>       Assunto. Default: Sem assunto                  "
    echo "   -d <DESTINATARIOS> Destinatarios                                  "
    echo "   -c <CC>            Em copia                                       " 
    echo "   -b <BCC>           Em copia oculta                                "
    echo "   -r <RESPONDER P/>  Responder para                                 "
    echo "   -n <NOME>          Nome do remetente. Default ${DEFAULT_SENDER}   "
    echo "   -t <TEXTO>         Texto do e-mail                                "
    echo "   -f <REMETENTE>     Remetente. Default: ${DEFAULT_SENDER_ADDRESS}  "
    echo "   -l <NIVEL>         Nivel do log. Valor padrao: ${DEFAULT_LOG_LEVEL}"
    echo "   -o                 Escreve log em arquivo                         "
    echo "   -h                 Exibe ajuda                                    "
    echo "                                                                     "
    echo "   Exemplos:                                                         "
    echo "      $0 -s Assunto -d iep@claro.com.br -t Teste                     "
}

#===============================================================
#
# Define nível de log
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
# Define arquivo de log
#
#===============================================================
function setLogFile()
{
    # cria diretorio, caso nao exista
    mkdir -p "${HOME_DIR}/log"

    # define arquivo de log
    LOG_FILE="${HOME_DIR}/log/mail.log"
    LOG_FILE_PARAM="-logfile=${LOG_FILE}"
}

function get_attachment()
{
    _input_file=$1

    if [ -f  "$_input_file" ];
    then
        attachment=$(readlink -f $_input_file)
    else
        echo "Arquivo nao encontrado: '$_input_file'"
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
while getopts s:t:d:n:f:c:r:a:l:oh opt; do
    case ${opt} in
        s)
            subject="${OPTARG}"
            ;;
        
        t)
            body="${OPTARG}"
            ;;
        d)
            address="${OPTARG}"
            ;;
        n)
            sender="${OPTARG}"
            ;;
        f)
            sender_address="${OPTARG}"
            ;;
        c)
            cc="${OPTARG}"
            ;;
        b)
            bcc="${OPTARG}"
            ;;
        r)
            reply_to="${OPTARG}"
            ;;
        a)
            get_attachment "${OPTARG}"
            ;;
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


IN_PARAMS="-param:iep.job.mail.subject='${subject}'"
IN_PARAMS="${IN_PARAMS} -param:iep.job.mail.body='${body}'"
IN_PARAMS="${IN_PARAMS} -param:iep.job.mail.address='${address}'"
IN_PARAMS="${IN_PARAMS} -param:iep.job.mail.sender=${sender}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.mail.sender_address=${sender_address}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.mail.cc=${cc}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.mail.bcc=${bcc}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.mail.reply_to=${reply_to}"
IN_PARAMS="${IN_PARAMS} -param:iep.job.mail.attachment=${attachment}"


bash -l -c "${PDI_BIN} -file=${IEP_PENTAHO_HOME}/common/pdi/${JOB_FILE} ${IN_PARAMS} ${LOG_FILE_PARAM} -level=${LOG_LEVEL}"



