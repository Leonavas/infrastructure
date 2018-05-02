#!/bin/bash

if [ $# -eq 3 ];
then
    SPLIT_CFG_FILE=${1}
    VOLUME_CFG_FILE=${2}
    LEFTOVER_CFG_FILE=${3}
else
    echo "Usage: $0 <SPLIT_CFG_FILE> <VOLUME_CFG_FILE> <LEFTOVER_CFG_FILE>"
    exit 1
fi

#===============================================================
#   CONSTANTES
#===============================================================

TODAY=$(date +%Y%m%d)
TOMORROW=$(date --date="1 day" +%Y%m%d)

HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
BIN_DIR=${HOME_DIR}"/bin"

rm -rf ${HOME_DIR}"/trunc/"* ${HOME_DIR}"/split/"*

${BIN_DIR}"/run-split.sh" ${SPLIT_CFG_FILE} ${TODAY} ${TOMORROW}

${BIN_DIR}"/run-volume-control.sh" ${VOLUME_CFG_FILE} ${LEFTOVER_CFG_FILE} ${TODAY}

${BIN_DIR}"/run-volume-control.sh" ${VOLUME_CFG_FILE} ${LEFTOVER_CFG_FILE} ${TOMORROW}

TRUNC_DIR=/opt/openidea/acm/operator/claro/report/mailing/trunc

