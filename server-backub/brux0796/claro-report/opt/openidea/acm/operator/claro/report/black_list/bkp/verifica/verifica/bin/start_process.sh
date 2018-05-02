#!/bin/bash

CURRENT_DATE=$(date +%Y%m%d) #YYYYMMDD

PDI_BIN=/opt/openidea/programs/pentaho_kettle/data-integration/kitchen.sh
DIR=/opt/openidea/acm/operator/claro/report/black_list/bkp/verifica/verifica

log_file="${DIR}/log/log_${CURRENT_DATE}.log"
echo "inicio pentaho ############################"
$PDI_BIN -file="$DIR"/pdi/job/start.kjb -level=basic > ${log_file}
echo "termino pentaho ##############################"
