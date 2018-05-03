#!/bin/bash

INFILE=$1
LOGFILE=log/recharge_listener.log
DISCARDS=log/discards.log
TMP=file.tmp
VALIDS=valids.tmp
UNPROCESSED=unprocessed.tmp
CONFIG8=/opt/openidea/acm/operator/claro/config/8digitos.cfg
CONFIG9=/opt/openidea/acm/operator/claro/config/9digitos.cfg
DDD9=$(awk '{ if (NR == 1) printf $1;  else  printf "|"$1 } END { printf "\n" }' $CONFIG9)
DDD8=$(awk '{ if (NR == 1) printf $1;  else  printf "|"$1 } END { printf "\n" }' $CONFIG8)
EMPTYS=log/empty.log
LOG4SH_DIR=/opt/openidea/acm/operator/claro/config
HOME_DIR=/opt/openidea/acm/operator/claro/recharge
LOG4SH_PROPERTIES=$HOME_DIR/config/log4sh/recharge_throughput.properties

# load log4sh
if [ -r $LOG4SH_DIR/log4sh ]; then
  LOG4SH_CONFIGURATION=$LOG4SH_PROPERTIES . $LOG4SH_DIR/log4sh
else
  echo "ERROR: could not load (log4sh)" >&2
  exit 1
fi

if [[ -f $INFILE ]]; then

    echo -e "Starting validation of in file "$INFILE >> $LOGFILE
    ret=0

    if [[ $(cat $INFILE | wc -l) -eq 0 ]]; then
        echo -e $INFILE >> $EMPTYS
        echo -e "Adding file "$INFILE" emptys file " >> $LOGFILE
        echo -e "Validation complete!\n" >> $LOGFILE
        echo -e ""      
        rm $INFILE 
        ret=-1
    else

        if [[ $(tail -1 $INFILE | grep -E -x 'T\|.*\|.*' | wc -l) -ne 1 ]] || [[ $(head -1 $INFILE | grep -E -x 'H\|SQ_RECARGA\|NU_MSISDN\|CD_TIPO_RECARGA\|DT_RECARGA\|HR_RECARGA\|VL_VOUCHER\|CD_GRUPO_CARTAO\|PC_PACOTE' | wc -l) -ne 1 ]]; then
            echo -e "In file '"$INFILE"' does not have header or tail line. Aborting." >> $LOGFILE
            exit 1
        else
            sed -e '2,$!d' -e '$d' $INFILE > $TMP
    
            #echo -e "Started discarding files from execution of file: "$INFILE  >> $DISCARDS
            #grep -E -x -v ".*\|(($DDD9)[0-9]{8,9}|($DDD8)[0-9]{8})\|.*\|2013[0-1][0-9][0-9]{2}\|.*\|[0-9]{1,3}\.[0-9]*\|.*\|.*" $TMP >> $DISCARDS
            #echo -e "DONE\n" >> $DISCARDS

            grep -E -x ".*\|[0-9]{10,11}\|.*\|2014[0-1][0-9][0-9]{2}\|.*\|[0-9]{1,3}\.[0-9]*\|.*\|.*" $TMP > $VALIDS
            rm $TMP
        fi

        echo -e "Validation complete!\n" >> $LOGFILE
    fi
    exit $ret
else
    echo -e "Usage: ./recharge_parser.sh <VALID INPUT FILE>"
    exit -1
fi

