#!/bin/sh
FILENAME=$1
#Filename_HT = file apos o sed retirar head e tail.
FILENAME_HT=/opt/openidea/acm/operator/claro/recharge
#Variaveis de parametros de configuracao
HOME_DIR=/opt/openidea/acm/operator/claro/config
LOG4SH_DIR=/opt/openidea/acm/operator/claro/config
LOG4SH_PROPERTIES=/opt/openidea/acm/operator/claro/recharge/config/log4sh/recharge_throughput.properties
CONF=$HOME_DIR/config_throughput.cfg
RECHARGE_THROUGHPUT_LEVEL=$(cat $CONF |grep RECHARGE_THROUGHPUT_LEVEL | awk '{print $2}' FS=\=)
DDD_IGNORE_RECHARGE=$(cat $CONF |grep DDD_IGNORE_RECHARGE | awk '{print $2}' FS=\=)

DATA=$(date +%y%m%d)
DIR=/opt/openidea/acm/operator/claro/recharge
pidfile=$DIR/recharge.pid
LOGFILE=log/recharge_listener.log

# load log4sh
if [ -r $LOG4SH_DIR/log4sh ]; then
    LOG4SH_CONFIGURATION=$LOG4SH_PROPERTIES . $LOG4SH_DIR/log4sh
else
    echo "ERROR: could not load (log4sh)" >&2
    exit 1
fi

if [ -e $pidfile ]; then
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

if [[ -f $FILENAME && -s $FILENAME ]]; then
    FILESIZE=$(wc -l $FILENAME | awk '{print $1}')
    #echo -e "Started processing file: " $FILENAME >> $LOGFILE
    logger_info "Iniciando processo"

    logger_info "Retirando o head e tail do arquivo"
    #Retirar o head e tail
    sed -e '2,$!d' -e '$d' $FILENAME > $FILENAME_HT/recharge_ht.tmp

    logger_info "Capturando os DDDs a serem ignorados"
    if [ $DDD_IGNORE_RECHARGE != "00" ]; then
        logger_info "Removendo registros de DDDs de acordo com registro de throughput"
        grep -E -x -v ".*\|($DDD_IGNORE_RECHARGE)[0-9]{8,9}\|.*\|20..[0-1][0-9][0-9]{2}\|.*\|[0-9]{1,3}\.[0-9]*\|.*\|.*" $FILENAME_HT/recharge_ht.tmp > valids_ddds.tmp
        cat valids_ddds.tmp > $FILENAME_HT/recharge_ht.tmp
        rm valids_ddds.tmp
    fi  

    logger_info "Quebrando o arquivo, para definir o quanto sera processado"
    #Quebra o arquivo, para definirmos o quanto sera processado

    #O parametro define o que vai passar: de 0 a 99 (0 = nada passa; 99 = passa tudo)
    awk -v data=$DATA -v recharge_throughput_level=$RECHARGE_THROUGHPUT_LEVEL -v sqt="'" '{
        if((($2 % 100) + 1) <= recharge_throughput_level) {       
            msisdn=$2;
            ddd=substr(msisdn, 1, 2);  
        
            #Insere o nono digito
            #
            if(ddd > 40 && ddd < 60) {
                number=substr(msisdn, 3);
                if(length(number) == 8){
                    number= "9" number;
                }
                msisdn=ddd number;
            };
            
            print "1," substr(data,5) "," sqt $4$5 sqt "," sqt msisdn sqt "," sqt "Claro-Pre" sqt "," sqt $3 sqt "," $6 "," $6 "," sqt substr($2,0,2) sqt;
        }
    }' FS="|" < $FILENAME_HT/recharge_ht.tmp > $DIR/recharge.csv

    #echo -e "Done processing: "$(date) >> $LOGFILE
    #mv $FILENAME $DIR/processed 
    logger_info "Excluindo arquivos temporarios"
    rm $FILENAME_HT/recharge_ht.tmp
    logger_info "Finalizado com sucesso"
else
    logger_error "Parametro de entrada invalido"
    echo -e "Usage: ./recharge_parser.sh <VALID INPUT FILE>"
    exit -1
fi

rm $pidfile
