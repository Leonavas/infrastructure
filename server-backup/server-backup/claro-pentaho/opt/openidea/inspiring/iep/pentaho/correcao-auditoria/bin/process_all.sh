#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"

for f in $HOME_DIR/src/*; do 
    ref_date=$(echo $f | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}_[[:digit:]]{2}')

    echo "Processando arquivo $f"
    $HOME_DIR/bin/start_process.sh -d $ref_date -o

    mv $f $HOME_DIR/prc
done


