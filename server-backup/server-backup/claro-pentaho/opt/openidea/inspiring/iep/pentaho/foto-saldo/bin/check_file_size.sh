#!/bin/bash

# Variaveis necessarias
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
DATE=$1
PAST_DATE=$2
LIMIT=$3
OLD_FILE_SIZE=$(stat -c %s ${HOME_DIR}/processed/UPLIFT_SALDOS_${PAST_DATE}.txt.gz)
CURRENT_FILE_SIZE=$(stat -c %s ${HOME_DIR}/tmp/prc/UPLIFT_SALDOS_${DATE}.txt.gz)

FILE_REF=$(( (OLD_FILE_SIZE * LIMIT) / 100))

if [ $CURRENT_FILE_SIZE -lt $FILE_REF ];
then
    exit 1
fi

exit 0
