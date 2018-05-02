#!/bin/bash

if [ $# -lt 2 ];
then
    echo -e "Usage: $0 <date|days> <YYYYMMDD|DAYS_AGO>"
    exit 1
else
    if [ $1 = "date" ];
    then
	REPORT_DATE=$2
    elif [ $1 = "days" ];
    then
        REPORT_DATE=$(date --date="$2 days ago" +%Y%m%d) #YYYYMMDD
    else
        echo -e "Usage: $0 <date|days> <YYYYMMDD|DAYS_AGO>"
        exit 1
    fi

    TRANSACTION_PART=$(date --date=$REPORT_DATE +%-j) #day of the year
fi

job_start_exec_time=$(date +%s)

DIR=/opt/openidea/acm/operator/claro/report/movement_extraction
CONFIG_FILE=$DIR/cfg/movement_extraction.cfg

################################################################################
# Reads the configuration
################################################################################
TO=$(cat $CONFIG_FILE | grep to | awk '{ if ($1 == "to") print $2}' FS=\=)
QUERY_FILE=$DIR"/cfg/query/"$(cat $CONFIG_FILE | grep query_file | awk '{ if ($1 == "query_file") print $2}' FS=\=)

################################################################################
# LOG4SH
################################################################################
LOG4SH_PROPERTIES=$DIR/cfg/log4sh/movement_extraction.log4sh
LOG4SH_DIR=/opt/openidea/acm/operator/claro/config
if [ -r $LOG4SH_DIR/log4sh ];
then
  LOG4SH_CONFIGURATION=$LOG4SH_PROPERTIES . $LOG4SH_DIR/log4sh
  logger_setLevel INFO
else
  echo "ERROR: could not load (log4sh)" >&2
  exit 1
fi

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=$DIR"/movement_extraction_"$REPORT_DATE"_P"$TRANSACTION_PART".pid"

if [ -e $pidfile ];
then
    pid=`cat $pidfile`

    if kill -0 &> /dev/null $pid;
    then
        echo "Already running"
        logger_error "Already running"
        exit 1
    else
        rm $pidfile
    fi
fi

echo $$ > $pidfile

rm -f $DIR"/tmp/"*.*

function extract_db_data () {

    if [ ! -s $DIR"/out/Base_Campanhas_"$REPORT_DATE"_P"$TRANSACTION_PART".txt.gz" ]
    then
        TMP_QUERY_FILE=$DIR"/tmp/movement_extraction_"$REPORT_DATE"_P"$TRANSACTION_PART".sql"    
        SED_ARG_BASE="s/#prc_date/$REPORT_DATE/g;";
        SED_ARG=$SED_ARG_BASE"s/#partition/P$REPORT_DATE/g;"
        cat $QUERY_FILE | sed -e "$SED_ARG" > $TMP_QUERY_FILE
        TMP_OUTPUT_FILE=$DIR"/tmp/Base_Campanhas_"$REPORT_DATE"_P"$TRANSACTION_PART".txt"
        /opt/openidea/acm/operator/claro/query_mailer/bin/query_csv.sh ACM_SOL_APP $TMP_QUERY_FILE > $TMP_OUTPUT_FILE
        rm $TMP_QUERY_FILE
        gzip -9 $TMP_OUTPUT_FILE
        mv $TMP_OUTPUT_FILE".gz" $DIR/out/
    fi
}

function send_err_mail() {
    zcat $DIR"/out/Base_Campanhas_"$REPORT_DATE".err.gz" | sed '1d' |awk 'BEGIN {print "CPGN_ID;INI_ST;FIN_ST"} {k=$2";"$5";"$6; l[k]++} END{for (i in l) {print i}}' FS=";" > $DIR"/err/unmapped_"$REPORT_DATE".csv"
    TITLE="***** ATENCAO ***** Estados não mapeados de Campanhas - "$REPORT_DATE
    $DIR/bin/mail.sh "$DIR/err" "unmapped_"$REPORT_DATE".csv" "$TITLE" "$TO"
    rm $DIR"/out/Base_Campanhas_"$REPORT_DATE".err.gz"
}

function send_mail() {
    TITLE="Uplift::Base Campanhas - "$REPORT_DATE
    $DIR/bin/mail.sh "$DIR/tmp" "Base_Campanhas_$REPORT_DATE.txt" "$TITLE" "$TO"
}

logger_info "Starting extraction of Campaign Movements from "$REPORT_DATE", partition P"$TRANSACTION_PART"."
extract_db_data
checkpoint_time=$(date +%s)
time_in_sec=$(($checkpoint_time-$job_start_exec_time))
logger_info "Campaign Movements extraction from "$REPORT_DATE", partition P"$TRANSACTION_PART" generated successfully in "$time_in_sec"s."

logger_info "Starting Pentaho Data Analysis."
$DIR/bin/pdi-MovementExtraction.sh > $DIR/log/pdi-MovementExtraction-$REPORT_DATE.log
checkpoint_time=$(date +%s)
time_in_sec=$(($checkpoint_time-$job_start_exec_time))
logger_info "Pentaho Data Analysis completed in "$time_in_sec"s."

if [ -e $DIR/out/Base_Campanhas_$REPORT_DATE.err.gz ]
then
    start_exec_time=$(date +%s)
    send_err_mail
    end_exec_time=$(date +%s)
    time_in_sec=$(($end_exec_time-$start_exec_time))
    logger_info "Error mail sent in "$time_in_sec"s."
else
    start_exec_time=$(date +%s)
    send_mail
    end_exec_time=$(date +%s)
    time_in_sec=$(($end_exec_time-$start_exec_time))
    logger_info "Success mail sent in "$time_in_sec"s."
fi

rm $pidfile

exit 0;

