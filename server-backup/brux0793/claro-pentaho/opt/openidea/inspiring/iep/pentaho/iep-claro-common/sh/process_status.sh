#!/bin/bash

feedback_lines=50000

function check_env()
{
  if [ -z "$step_hint"  ] ||
     [ -z "$process_bin" ] ||
     [ -z "$input_file_pattern" ] ||
     [ -z "$log_file_pattern" ] ||
     [ -z "$HOME_DIR" ];
  then
      echo "Variaveis nao definidas, verificar script"
      exit 1
  fi
}

function check_running()
{
   check_env
   RUNNING=$(ps -ef | grep "${process_bin}" | wc -l)
}

function calc_avg_process_time()
{
    check_env
    avg_time=$(grep "${step_hint}" ${log_file} | tail -n 50 | awk -v old_time=0 '{
        d=$1" "$2;
        cmd="date --date=\""d"\" +%s";
        cmd | getline t;
        if(old_time > 0){
            diff=t-old_time; 
            nlinhas+=1;
            sum+=diff
        }
        old_time=t
        } END {
            print sum / nlinhas
        }')
    echo "Tempo medio para processar ${feedback_lines} linhas: ${avg_time} segundos"
    round_avg_time=$(printf "%.0f" $avg_time)
    last_date=$(grep "$step_hint" $log_file | tail -n1 | awk '{print$1" "$2}')   
    eta=$(( remaining_lines * round_avg_time / feedback_lines ))
    echo "Tempo estimado para termino: ${eta} segundos a partir de $last_date"
}

function show_status()
{
    check_env
    check_running $process_bin
    if [ $RUNNING -gt 1  ];
    then
        echo "Processo em execucao"
    else
        echo "Processo nao esta em execucao"
    fi
}

function show_progress()
{
    check_env
    echo "Verificando arquivo de entrada..."
    input_file=$(find ${HOME_DIR}/tmp -name "$input_file_pattern" | head -n1)
    if [ -z "$input_file" ];
    then
        echo "Nenhum arquivo em processamento"
        return 0
    fi

    echo "Arquivo em processamento: $(basename $input_file)"

    echo "Verificando tamanho do arquivo de entrada..."
    total_linhas=$(zcat $input_file | wc -l)
    printf "Numero de linhas para processar: %'d\n" $total_linhas
    
    log_file=$(ls -t "${HOME_DIR}/log/"${log_file_pattern} | head -n1)
    if [ -z "$log_file" ];
    then
        echo "Arquivo de log nao encontrado"
        return 0
    fi

    echo "Arquivo de log: ${log_file}"
    
    enviado_iep=$(grep "$step_hint" $log_file | tail -n1 | grep -o "[0-9]*$")
    if [ -z "$enviado_iep" ];
    then
        echo "Nenhum envio ao IEP computado no log"
        return 0
    fi

    progress=$(( 100 * enviado_iep / total_linhas ))
    printf "Enviados ao IEP: %'d (%d%% concluido)\n" $enviado_iep $progress
    remaining_lines=$(( total_linhas - enviado_iep ))

    printf "Linhas para acabar: %'d\n" $remaining_lines
    calc_avg_process_time $log_file
}

function show_results()
{
    check_env

    p_log_file=$1

    if [ -z "${p_log_file}" ];
    then
        log_file=$(ls -t "${HOME_DIR}/log/"${log_file_pattern} | head -n1)
    else
        log_file="${HOME_DIR}/log/${p_log_file}"
    fi

    if [ -z "$log_file" ];
    then
        echo "Arquivo de log nao encontrado"
        return 0
    fi

    echo "Arquivo de log: ${log_file}"
    resultado=$(tail -n 3 ${log_file} | grep "Kitchen - Finished\!$" | wc -l)
    
    if [ $resultado -eq 1 ];
    then
        echo "Executado com sucesso"
    else
        echo "Executado com erro"
    fi

    total_time=$(tail -n 1 ${log_file} | grep -o "after .* seconds.*\." | sed 's/after //g')
    process_times=$(tail -n 2 ${log_file} | head -n 1 | grep -oe "Start=.*$")
    echo "$process_times"
    echo "Tempo total: $total_time"

    # Verifica se existe a funcao success_report
    if [ -n "$(type -t output_report)" ] && [ "$(type -t output_report)" = function ];   
    then
        output_report "$log_file"
    fi
    

}

