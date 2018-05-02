#!/bin/bash

if [ -z "$1" ];
then
    CURRENT_DATE=$(date +%Y%m%d) #YYYYMMDD
else
    CURRENT_DATE=$1
fi


PDI_BIN=/opt/openidea/programs/pentaho_kettle/data-integration/kitchen.sh
DIR=/opt/openidea/acm/operator/claro/report/recharge_avarage

echo "############################## inicio pentaho ############################"
$PDI_BIN -file="$DIR"/pdi/job/run.kjb -level=Basic "-param:acm.job.root_dir="$DIR "-param:current_date="$CURRENT_DATE
echo "############################## termino pentaho ##############################"
if [ $? -eq 0 ]; 
then
	echo "############################## fim #############################"
fi
