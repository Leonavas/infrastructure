#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
SQLLOADER_DIR="${HOME_DIR}/ldr"

#===============================================================
#   FUNCOES
#===============================================================
function validate()
{

	if [ ! -f "$1" ];
	then
	    echo "Arquivo de entrada nao encontrado: $1"
		exit 1
	fi

    if [ -z "$2" ];
	then
	    echo "Conexao com o banco de dados nao informada"
		exit 1
	fi

}

#===============================================================
#   FLUXO PRINCIPAL
#===============================================================

# Obtem o nome do arquivo
FILENAME=$1
DATAFILE="${SQLLOADER_DIR}/processing/${FILENAME}"

# Carrega a conexao do arquivo de entrada
LDR_USERID=$2

# valida as entradas
validate $DATAFILE $LDR_USERID

echo "Processando arquivo ${DATAFILE}"

# Define os parametros do sqlloader
LDR_PARAMS="userid=${LDR_USERID}"
LDR_PARAMS="$LDR_PARAMS control=${SQLLOADER_DIR}/ctl/acm_sol_transactions-control.cfg"
LDR_PARAMS="$LDR_PARAMS log=${SQLLOADER_DIR}/log/${FILENAME}.log"
LDR_PARAMS="$LDR_PARAMS bad=${SQLLOADER_DIR}/error/${FILENAME}.bad"
LDR_PARAMS="$LDR_PARAMS discard=${SQLLOADER_DIR}/error/${FILENAME}.discard"
LDR_PARAMS="$LDR_PARAMS data=${DATAFILE}"

# Cria diretorios sob demanda
mkdir -p ${SQLLOADER_DIR}/ctl ${SQLLOADER_DIR}/error ${SQLLOADER_DIR}/log ${SQLLOADER_DIR}/processing

# Executa o SQL Loader
sqlldr ${LDR_PARAMS}
