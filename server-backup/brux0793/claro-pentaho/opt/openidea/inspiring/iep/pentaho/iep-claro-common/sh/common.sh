#!/bin/bash

#===============================================================
#
# Verifica se ja existe um processo rodando
#
#===============================================================
function checkPID()
{   
    PID_FILE=$1
    
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