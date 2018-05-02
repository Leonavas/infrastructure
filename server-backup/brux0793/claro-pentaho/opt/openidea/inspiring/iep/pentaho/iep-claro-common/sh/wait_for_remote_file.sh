#!/bin/bash

SSH_OPTIONS="-qo PasswordAuthentication=no -o StrictHostKeyChecking=yes"
OLD_FILE_SIZE=-1

TIME_TO_WAIT=120
TIME_TO_CHECK=15
WAIT_FILE_GROWTH=1

#===============================================================
#   FUNCOES
#===============================================================

function usage()
{
    echo "Uso: $0 <SERVIDOR> <ARQUIVO_REMOTO> [TEMPO_ESPERA] [TEMPO_VERIFICACAO] [VERIFICA_TAMANHO]"
    echo "    <SERVIDOR>: O servidor onde o arquivo remoto se encontra"
    echo "    <ARQUIVO_REMOTO>: Endereco do arquivo remoto"
    echo "    [TEMPO ESPERA]: (Opcional) Tempo de espera maximo do arquivo"
    echo "    [TEMPO_VERIFICACAO]: (opcional) Tempo de verificacao do arquivo"
    echo "    [VERIFICA_TAMANHO]: (opcional) Verifica se o arquivo para de crescer (0 ou 1)"
}

#===============================================================
#   Verifica se continua esperando o arquivo ou para. Se nao
#   houver mais tempo retorna codigo de retorno 2
#   Parametros:
#      1: Tempo que comecou a verificacao
#===============================================================
function shall_wait_for_file()
{
    START_TIME=$1
    CHECK_TIME=$(date +%s)
    TIME_SINCE_FIRST_CHECK=$(( CHECK_TIME - START_TIME ))

    if [ $TIME_SINCE_FIRST_CHECK -ge $TIME_TO_WAIT ];
    then
        echo "Tempo de espera excedido"
        exit 2
    fi
}

#===============================================================
#   Verifica tamanho do arquivo remoto
#===============================================================
function get_file_size()
{
    echo "Verificando o arquivo..."
    CURRENT_FILE_SIZE=$(ssh ${SSH_OPTIONS} ${SERVER} stat -c %s ${FILENAME})
	
	GET_FILE_SIZE_RETURN=$?
    
	if [ $GET_FILE_SIZE_RETURN -eq 255 ];
    then
        echo "Nao foi possivel conectar ao host ${SERVER}"
        exit 255
    elif [ $GET_FILE_SIZE_RETURN -ne 0 ];
	then
		echo "Erro ao verificar arquivo, retorno: ${GET_FILE_SIZE_RETURN}"
	fi
	
	return $GET_FILE_SIZE_RETURN
}

#===============================================================
#   Aguarda para verificar um arquivo remoto
#===============================================================
function wait_for_file()
{   
    shall_wait_for_file $FIRST_FILE_CHECK_TIME

    # espera pelo tempo de verificacao
    echo "Aguardando $TIME_TO_CHECK segundos para verificar o arquivo"
    sleep $TIME_TO_CHECK

    # Obtem o tamanho do arquivo
    get_file_size $FIRST_FILE_CHECK_TIME

    FILE_SIZE_RETURN=$?
    if [ -z $CURRENT_FILE_SIZE ] || [ $FILE_SIZE_RETURN -ne 0 ];
    then
        echo "Arquivo nao encontrado!"
        wait_for_file
    else
        if [ $WAIT_FILE_GROWTH -eq 1 ];
        then
           echo "Arquivo encontrado, aguardando o arquivo parar de crescer"
            FIRST_CHECK_FILE_GROWTH_TIME=$(date +%s)
            wait_file_growth
        else
            echo "Arquivo encontrado!"
            exit 0
        fi
    fi

}

#===============================================================
#   Aguarda o arquivo parar de crescer
#===============================================================
function wait_file_growth()
{

    get_file_size
    
    FILE_SIZE_RETURN=$?
    if [ $FILE_SIZE_RETURN -ne 0 ];
    then
        echo "Erro enquanto esperava pelo arquivo terminar de crescer"
        exit $FILE_SIZE_RETURN
    fi

    echo "Tamanho anterior: $OLD_FILE_SIZE"
    echo "Tamanho atual: $CURRENT_FILE_SIZE"

    if [ $CURRENT_FILE_SIZE -gt $OLD_FILE_SIZE ];
    then
        echo "Aguardando $TIME_TO_CHECK segundos para o arquivo terminar de crescer"
        sleep $TIME_TO_CHECK

        shall_wait_for_file $FIRST_CHECK_FILE_GROWTH_TIME

        OLD_FILE_SIZE=$CURRENT_FILE_SIZE

        wait_file_growth
    else
        echo "Arquivo parou de crescer, finalizando..."
        exit 0
    fi

}

#===============================================================
#   MAIN SCRIPT
#===============================================================

# Verifica os parametros
if [ $# -eq 2 ];
then
    SERVER=$1
    FILENAME=$2
elif [ $# -eq 4 ];
then
    SERVER=$1
    FILENAME=$2
    TIME_TO_WAIT=$3
    TIME_TO_CHECK=$4
elif [ $# -eq 5 ];
then
    SERVER=$1
    FILENAME=$2
    TIME_TO_WAIT=$3
    TIME_TO_CHECK=$4
    WAIT_FILE_GROWTH=$5
else
    echo "Utilizacao incorreta"
    usage
    exit 1
fi

echo "Verificando arquivo ${FILENAME}"
echo "Host de destino: ${SERVER}"
echo "Tempo de espera: ${TIME_TO_WAIT}s"
echo "Tempo de verificacao: ${TIME_TO_CHECK}s"
echo "Espera arquivo crescer: ${WAIT_FILE_GROWTH}"

FIRST_FILE_CHECK_TIME=$(date +%s)

get_file_size
FILE_SIZE_RETURN=$?

if [ -z "$CURRENT_FILE_SIZE" ] || [[ $FILE_SIZE_RETURN -ne 0 ]];
then
    echo "Arquivo nao encontrado..."
    wait_for_file
else
    echo "Arquivo encontrado, aguardando o arquivo parar de crescer"
    FIRST_CHECK_FILE_GROWTH_TIME=$(date +%s)
    wait_file_growth
fi

