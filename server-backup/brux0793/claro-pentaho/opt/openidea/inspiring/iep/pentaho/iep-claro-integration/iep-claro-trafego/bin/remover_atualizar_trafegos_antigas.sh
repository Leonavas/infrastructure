#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
DEST_DIR=${HOME_DIR}"/bkl"
CURRENT_DAY=$(date -d '10:00:00' +%Y%m%d)
MONTH=$(date -d '' +%m)
LAST_DAY_MONTH=$(date -d ${MONTH}"/1 + 1 month - 1 day" "+%Y%m%d")

if [ ${LAST_DAY_MONTH} == ${CURRENT_DAY} ];
then
     rm ${DEST_DIR}"/"*".gz"
fi
