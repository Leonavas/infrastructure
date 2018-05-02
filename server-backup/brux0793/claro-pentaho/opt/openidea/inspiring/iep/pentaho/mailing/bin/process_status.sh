#!/bin/bash

# Variaveis necessarias
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
step_hint="Verifica resposta.0"
input_file_pattern="*\.txt\.gz"
log_file_pattern="mailing_*"
process_bin="mailing/bin/start_process.sh"

# Carrega script com funcoes comuns
source $IEP_PENTAHO_HOME/common/sh/process_status.sh


function usage()
{
    echo "Usage: $0 {status|progress}"
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

    *)
        usage
        exit 1
esac
