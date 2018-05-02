#!/bin/bash

DIR="$(cd "`dirname $0`/.." && pwd)"
DATE="$(date --date='-1 day'  +%Y%m%d%H%M%S)"

IN=$DIR/bin/aux/pcrf
DEST=$DIR/event_process/event/pacotes/prc

zcat ${IN}/*.gz >> $IN/UPLIFT_PCTS_CONTRATADOS_${DATE}_00001.txt

mv ${IN}/*.gz ${IN}/bkp

gzip ${IN}/UPLIFT_PCTS_CONTRATADOS_${DATE}_00001.txt

mv ${IN}/UPLIFT_PCTS_CONTRATADOS_${DATE}_00001.txt.gz ${DEST}


##################TRATA ARQUIVO##################
EXECUTE_FILE="exec_control_pacs.sh"
EXECUTE_DIR="/opt/openidea/acm/operator/claro/event_process/event/pacotes/control_pacs/bin"
#SERVER="brux0796"
#USER="acm"
FILE_DATE=$(date -u --date='-1 day' +%Y%m%d) #YYYYMMDD
PID="1122"${DATE}
#ssh ${USER}"@"${SERVER} ${EXECUTE_DIR}"/"${EXECUTE_FILE} ${PID} ${FILE_DATE}
${EXECUTE_DIR}"/"${EXECUTE_FILE} ${PID} ${FILE_DATE}



