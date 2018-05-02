#!/bin/bash

# Variaveis necessarias
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
step_hint="Verifica retorno.0"
input_file_pattern="portout_*\.txt\.gz"
log_file_pattern="iep-claro-portout_*"
process_bin="portout/bin/start_process.sh"

# Carrega script com funcoes comuns
source $IEP_PENTAHO_HOME/common/sh/process_status.sh


function usage()
{
    echo "Usage: $0 {status|progress}"
}


function output_report()
{
    p_logfile=$1
    total_lines=$(grep "Verifica retorno.0 - Finished processing" ${p_logfile} | grep -Eo "W\=[0-9]+\," | tr -d "W\=\,")
    lines_ok=$(grep "Gera Saída Sucesso.0 - Finished processing" ${p_logfile} | grep -Eo "W\=[0-9]+\," | tr -d "W\=\,")
    lines_nok=$(grep "Gera Saída Erro.0 - Finished processing" ${p_logfile} | grep -Eo "W\=[0-9]+\," | tr -d "W\=\,")

   printf "Total de linhas processadas: %'d\n" ${total_lines:-0}
   printf "Linhas processadas com sucesso: %'d\n" ${lines_ok:-0}
   printf "Linhas processadas com erro: %'d\n" ${lines_nok:-0}

   transitions_file=$(ls -t ${HOME_DIR}/out/transitions/ | head -n 1)

   if [ -f "${HOME_DIR}/out/transitions/${transitions_file}" ];
   then
       echo
       echo "Transicoes:"
       zcat ${HOME_DIR}/out/transitions/${transitions_file}
   fi

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
