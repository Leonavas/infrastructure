#!/bin/sh

DIR=/opt/openidea/acm/operator/claro/recharge
FILENAME=$1
VALIDSFILE=valids.tmp

if [ -s $FILENAME ]
then
#$DIR/validate_input.sh $1
#RETVAL=$?

#if [ $RETVAL -eq 0 ]; then
    $DIR/recharge_parser.sh $FILENAME
    RETPARSER=$?

    if [ $RETPARSER -eq 0 ]; then
        cd $DIR
#        sqlldr userid=ACM_EXT_APP/lft#2014@//acm-db:1521/P00LFT control=recharge.ctl log=log/recharge.log
        rm $DIR/recharge.csv

        cp $FILENAME /opt/openidea/acm/operator/claro/report/recharge_aggregation/unp/.
#        cp $FILENAME /opt/openidea/acm/operator/claro/report/recharge_aggregation/bkg/.

        gzip -9 $FILENAME

        scp $FILENAME.gz brux0793:/opt/openidea/inspiring/iep/pentaho/iep-claro-integration/iep-claro-recargas/src/.
        scp $FILENAME.gz brux0794:/opt/openidea/inspiring/alerta-claro/pentaho/alerta-claro-processar-recargas/src/.
        scp $FILENAME.gz brux0794:/opt/openidea/inspiring/alerta-claro/pentaho/alerta-claro-agrega-recargas/src/.

        scp $FILENAME.gz brux0794:/opt/openidea/inspiring/alerta-claro/pentaho/alerta-claro-inseridores/src/.

        mv $FILENAME.gz $DIR/processed
    fi
#fi
fi
