#!/bin/bash

if [ -z "$1" ];
then
    CURRENT_DATE=$(date +%Y%m%d) #YYYYMMDD
else
    CURRENT_DATE=$1
fi

CURR_FILE=EXT_CLI_PRE_PAGO_OPT_OUT_$CURRENT_DATE*

PDI_BIN=/opt/openidea/programs/pentaho_kettle/data-integration/kitchen.sh
DIR=/opt/openidea/acm/operator/claro/customer_update/ps8_optout
FETCHER_DIR=/opt/openidea/acm/operator/claro/fetcher/src/in_optout
CN_CFG_FILE=/opt/openidea/acm/operator/claro/report/common/src/DDD.csv

cp $FETCHER_DIR/$CURR_FILE $DIR/src/EXT_CLI_PRE_PAGO_OPT_OUT_$CURRENT_DATE.txt

if [ ! -f $DIR/src/$CURR_FILE ]
then
   exit
fi

if [ ! -s $DIR/src/EXT_CLI_PRE_PAGO_OPT_OUT_$CURRENT_DATE.txt ];
then
    exit
fi
log_file="${DIR}/log/log_${CURRENT_DATE}.log"
echo "inicio pentaho ############################"
$PDI_BIN -file="$DIR"/pdi/job/Run.kjb "-param:acm.job.root_dir="$DIR "-param:currentDate="$CURRENT_DATE "-param:acm.job.file.cfg.ndc="${CN_CFG_FILE} -level=basic > ${log_file}
echo "termino pentaho ##############################"

if [ $? -eq 0 ] 
then
	echo "inicio zip #############################"
	gzip $DIR/src/$CURR_FILE
	echo "antes de mover para processed ##############"
	mv $DIR/src/*.gz $DIR/processed
 	echo "moveu para processed ######################"
	gzip $DIR/out/uplift_optinout_$CURRENT_DATE.txt

        cp $DIR/out/uplift_optinout_$CURRENT_DATE.txt.gz /opt/openidea/acm/operator/claro/customer_update/balance-pdi/ext/unp/
       touch /opt/openidea/acm/operator/claro/customer_update/balance-pdi/ext/unp/uplift_optinout.file

        scp $DIR/out/uplift_optinout_$CURRENT_DATE.txt.gz acm@brux0794:/opt/openidea/acm/operator/claro/customer_update/optout/ext/
	rm $FETCHER_DIR/$CURR_FILE
fi
