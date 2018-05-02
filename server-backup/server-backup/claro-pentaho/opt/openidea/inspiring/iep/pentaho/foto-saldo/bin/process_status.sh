#!/bin/bash

# Variaveis necessarias
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
step_hint="Verifica resposta.0"
input_file_pattern="UPLIFT_*\.txt\.gz"
log_file_pattern="foto_saldo_*"
process_bin="foto-saldo/bin/start_process.sh"

# Carrega script com funcoes comuns
source $IEP_PENTAHO_HOME/common/sh/process_status.sh


function usage()
{
    echo "Usage: $0 {status|progress}"
}

function show_progress()
{
    echo "Progresso deste processo nao esta disponivel"
}

function output_report()
{
    p_logfile=$1
    total_processado=$(grep "Balance Join.0 - Finished processing" ${p_logfile} | grep -Eo "W\=[0-9]+\," | tr -d "W\=\,")
    clientes_removidos=$(grep "Delete.0 - Finished processing" ${p_logfile} | grep -Eo "W\=[0-9]+\," | tr -d "W\=\,")
    clientes_criados=$(grep "New.0 - Finished processing" ${p_logfile} | grep -Eo "W\=[0-9]+\," | tr -d "W\=\,")
    clientes_atualizados=$(grep "Update.0 - Finished processing" ${p_logfile} | grep -Eo "W\=[0-9]+\," | tr -d "W\=\,")

    printf "Total de linhas processadas: %'d\n" ${total_processado:-0}
    printf "Clientes removidos: %'d\n" ${clientes_removidos:-0}
    printf "Clientes criados: %'d\n" ${clientes_criados:-0}
    printf "Clientes atualizados: %'d\n" ${clientes_atualizados:-0}
}


if [ -f "${HOME_DIR}/tmp/pid" ];
then
    pid=$(cat ${HOME_DIR}/tmp/pid)
fi

cmd=$1

case "$cmd" in
    status)
        show_status
        ;;

    progress)
        show_progress
        ;;

    results)
        show_results
        ;;
    *)
        usage
        exit 1
esac
