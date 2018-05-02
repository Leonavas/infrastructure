#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"


function check_msisdn()
{
    p_actor_id=$1
    p_file=$2
    response=$(curl -s -D - -o - $IEP_CLARO_URL/rs/actor/${p_actor_id})
    error_code=$(echo "$response" | grep "X-SMKT-ErrorCode" | sed "s/X\-SMKT\-ErrorCode\: //g" | tr -d '[:space:]')
    error_message=$(echo "$response" | grep "X-SMKT-ErrorMessage" | sed 's/X\-SMKT\-ErrorMessage\: //g' | tr -d '[:space:]')
    actor=$(echo "$response" | tail -n1 | tr -d '[:space:]')

    if [ "$error_code" != "SMKT_0000" ];
    then
        echo "${error_code};${error_message};${p_actor_id}" >> "$HOME_DIR/out/chk/$p_file.errors"
    elif [ -n "$actor"  ];
    then
        echo "$actor" >> "$HOME_DIR/out/chk/$p_file.success"
    fi

}

function check_msisdn_from_file()
{
    input_file="$1"
    filename=$(basename $input_file) 
 
    OLD_IFS="$IFS"
    IFS=";"
    while read -r dt et ec ts type data; do
        actor_id=$(echo $data | grep -oP 'cliente","id":"\K[^"]+')

        if [ -n "$actor_id" ];
        then
            echo "Verificando o cliente $actor_id"
            check_msisdn $actor_id $filename
        fi

    done < "$input_file"
    
    IFS="$OLD_IFS"
}



for f in $HOME_DIR/out/error/*.log; do 

   echo "Processando arquivo $f"
   check_msisdn_from_file $f

done


