#!/bin/bash


# Variaveis necessarias
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
step_hint="Verifica retorno.0"
input_file_pattern="dw_master_trafego_*\.txt\.gz"
log_file_pattern="iep-claro-trafego-gera-eventos_*"
process_bin="iep-claro-integration/iep-claro-trafego/bin/generate_events.sh"

# Carrega script com funcoes comuns
source $IEP_PENTAHO_HOME/iep-claro-common/sh/process_status.sh


function output_report()
{
    p_logfile=$1
    clientes_mapeados=$(grep -oP "Clientes mapeados.0 - Finished processing.*W=\K[^,]+" ${p_logfile})
    linhas_nao_atualizados=$(grep -oP "Escreve linhas não atualizadas.0 - Finished processing.*W=\K[^,]+" ${p_logfile})
    eventos_criados=$(grep -oP "Monta evento.0 - Finished processing.*W=\K[^,]+" ${p_logfile})

    printf "Total de Clientes Mapeados: %'d\n" ${clientes_mapeados:-0}
    printf "Linhas nao atualizadas: %'d\n" ${linhas_nao_atualizados:-0}
    printf "Total de Eventos criados: %'d\n" ${eventos_criados:-0}

}

show_results

